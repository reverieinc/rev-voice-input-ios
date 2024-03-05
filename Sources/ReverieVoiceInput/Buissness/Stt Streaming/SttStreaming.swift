/*
 * All Rights Reserved. Copyright 2024. Reverie Language Technologies Limited.(https://reverieinc.com/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import Foundation
import AVFAudio
import Starscream
import Network



/// Class to handle STT call call using Recording and Websockets
class SttStreaming :NSObject,WebSocketDelegate, AVAudioRecorderDelegate{
    private var appId:String
    private var apiKey:String
    private var domain:String
    private var lang:String
    private var isSocketOpen=false
    private var dataBuffer=Data()
    private var logging=Logging.TRUE
    private var isDissmissed=false
    private static var inProcess=false
    
    //let networkMonitor = NetworkMonitor.shared
    public init(appId:String,apiKey:String,domain:String,lang:String,logging:String)
    {
        self.appId=appId
        self.apiKey=apiKey
        self.domain=domain
        self.lang=lang
        self.logging=logging
        isDissmissed=false
        
    }
    
    
    
    private var delegate:StreamingDelegate?
    
    var socket : WebSocket!
    public func setDelegate(delegate:StreamingDelegate)
    {
        self.delegate=delegate
    }
    
    var audioSession = AVAudioSession.sharedInstance();
    var engine = AVAudioEngine()
    var inputNode : AVAudioInputNode!
    var isReceivedData=false
    var timer:Timer?
    var urlStr = ""
    lazy var downAudioFormat: AVAudioFormat = {
        let avAudioChannelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Mono)!
        return AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: 16000.0,
            interleaved: true,
            channelLayout: avAudioChannelLayout)
    }()
    
    public func startStreaming()
    {   Logger.printLog(string: SttStreaming.inProcess)
        if(!SttStreaming.inProcess)
        {
        self.dataBuffer.removeAll()
        socketSetup();
        recordData();
        isReceivedData=false
        SttStreaming.inProcess=true
        isDissmissed=false
        self.delegate?.onStartRecording(isTrue: true)
        }
     
    }
    public func stopStreaming()
    {      self.isSocketOpen=false
        SttStreaming.inProcess=false
        isDissmissed=true
        timer?.invalidate()
        if(isSocketOpen)
        {Logger.printLog(string:"Socket Connection Disconnecting")
            socket.disconnect()
            engine.stop()
            self.delegate?.onEndRecording(isTrue: true)}
        self.engine.stop()
        
    }
    public func stopStreamingForFinal()
    {            self.isSocketOpen=false
        self.engine.stop()
        self.engine.inputNode.reset()
        SttStreaming.inProcess=false
        
        timer?.invalidate()
        if let data = "--EOF--".data(using: .utf8) {
            // Send the Data using WebSocket
            self.socket?.write(data: data)
            //self.socket.disconnect()
        } else {
            Logger.printLog(string:"Failed to convert string to data.")
        }
        self.delegate?.onEndRecording(isTrue: true)
        self.isSocketOpen=false
    }
    
    func socketSetup() {
        urlStr = "\(Constants.STREAM_URL)?apikey=\(apiKey)&appid=\(appId)&appname=stt_stream&src_lang=\(lang)&domain=\(domain)&logging=\(logging)"
        
        Logger.printLog(string:urlStr)
        
        let request = URLRequest(url: URL(string: urlStr)!)
        
        socket = WebSocket(request: request)
        socket.delegate = self
        
        let timeoutInterval: TimeInterval = 10
        timer =     Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            if(!(self!.isSocketOpen))
            { self?.socket.disconnect()
                self?.engine.stop()
                
                self?.delegate?.onEndRecording(isTrue: true)
                SttStreaming.inProcess=false
                self?.delegate?.onError(data: "Connection Timeout")}
        }
        self.socket.connect()
        
    }
    
    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
            Logger.printLog(string:"Connected")
            timer?.invalidate()
            timer=nil
            // inputNode.reset()
            isSocketOpen=true
            
            
        case .disconnected(_, _):
            if(isSocketOpen)
            {
                self.delegate?.onError(data: "Timeout")
            }
            Logger.printLog(string:"Disconnected")
            isSocketOpen=false
            SttStreaming.inProcess=false
            
            
            self.delegate?.onEndRecording(isTrue: true)
            
            self.inputNode.reset()
            self.inputNode.removeTap(onBus: 0)
            
            self.engine.stop()
            
        case .text(let text):
            isReceivedData=true
            if let str = convertToDictionary(text: text), let displayText = str[JsonLabels.display_text] as? String, displayText != "", let final = str[JsonLabels.final] as? Bool{
                Logger.printLog(string:displayText)
                
                DispatchQueue.main.async {
                    if(!self.isDissmissed)
                    {     self.delegate?.onResult(data:text)}
                    
                    Logger.printLog(string:text)
                    
                }
                if(final)
                {
                    self.inputNode.reset()
                    self.inputNode.removeTap(onBus: 0)
                    Logger.printLog(string: "Disconnecting")
                    self.engine.stop()
                    self.isSocketOpen=false
                    self.socket.disconnect()
                    SttStreaming.inProcess=false
                    
                }
                
                
            }
            
            
            
        case .binary(let data):
            Logger.printLog(string:"Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            self.inputNode.reset()
            self.inputNode.removeTap(onBus: 0)
            self.delegate?.onEndRecording(isTrue: true)
            self.engine.stop()
            SttStreaming.inProcess=false
            
            isSocketOpen=false
            Logger.printLog(string:"Cancelled")
        case .error(let error):
            self.inputNode.reset()
            self.inputNode.removeTap(onBus: 0)
            self.delegate?.onEndRecording(isTrue: true)
            self.engine.stop()
            SttStreaming.inProcess=false
            Logger.printLog(string:"Error Ns \(String(describing: error as? NSError))")
            self.isSocketOpen=false
            DispatchQueue.main.async {
                
                if((error as? HTTPUpgradeError ) != nil){
                    
                    self.delegate?.onError(data: String(describing: error as? NSError))
                }
                
            }
            break
        case .peerClosed:
            break
        }
        
    }
    
    func didReceiveError(socket: WebSocketClient, error: Error) {
        
        Logger.printLog(string:error.localizedDescription)
        self.delegate?.onError(data: String(describing: error as? NSError))
//        SttStreaming.inProcess=false
    }
    
    func toNSData(PCMBuffer: AVAudioPCMBuffer) -> Data {
        
        let channels = UnsafeBufferPointer(start: PCMBuffer.int16ChannelData, count: Int(PCMBuffer.frameLength))
        let ch0Data = Data(bytes: channels[0], count:Int(PCMBuffer.frameCapacity * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
    }
    
    func recordData() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            Logger.printLog(string:"audioSession properties weren't set because of an error.")
            return
        }
        
        engine = AVAudioEngine()
        inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        Logger.printLog(string:inputFormat.sampleRate)
        let recordingFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 16000.0, channels: 1, interleaved: false)
        
        
        let formatConverter =  AVAudioConverter(from:inputFormat, to: recordingFormat!)
        
        
        let downSampleRate: Double = downAudioFormat.sampleRate
        let ratio: Float = Float(inputFormat.sampleRate)/Float(downSampleRate)
        
        
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { (buffer, time) in
            
            let capacity = UInt32(Float(buffer.frameCapacity)/ratio)
            
            if let pcmBuffer = AVAudioPCMBuffer(pcmFormat: recordingFormat!, frameCapacity: capacity) {
                var error: NSError? = nil
                
                let inputBlock: AVAudioConverterInputBlock = {inNumPackets, outStatus in
                    outStatus.pointee = AVAudioConverterInputStatus.haveData
                    return buffer
                }
                
                formatConverter?.convert(to: pcmBuffer, error: &error, withInputFrom: inputBlock)
                
                let data = self.toNSData(PCMBuffer: pcmBuffer)
                // Logger.printLog(string:"Socket Write")
                self.dataBuffer.append(data)
                
                
                if(self.isSocketOpen){
                    self.socket.write(data: self.dataBuffer)
                    {
                        Logger.printLog(string:"Socket Write Complete1")
                        self.inputNode.reset()
                        self.dataBuffer.removeAll()
                    }}
                if(self.isDissmissed)
                {
                    self.engine.stop()
                    self.engine.inputNode.reset()
                    self.socket.disconnect()
                    
                }
            }
        }
        
        self.engine.prepare()
        
        do
        {
            try self.engine.start()
        }
        catch
        {
            Logger.printLog(string:error.localizedDescription)
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Logger.printLog(string:error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    
}

