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

/// Class to initiate Voice Search WIthout UI
class VoiceInputWithoutUI:StreamingDelegate{
   
    
    func onResult(data: String)
    {
        if let jsonData = data.data(using: .utf8) {
            do {
                // Decode JSON data into a Person struct
                let voiceSearchData = try JSONDecoder().decode(VoiceInputResultData.self, from: jsonData)
                if(voiceSearchData.final)
                {
                    VoiceInputWithoutUI.inProcess=false
                }
                
                DispatchQueue.main.async{
                    self.voiceSearchDelegate.onResult(data: voiceSearchData)
                    Logger.printLog(string:data)
                }
            } catch {
                Logger.printLog(string:"Error decoding JSON: \(error)")
            }
        } else {
            Logger.printLog(string:"Error converting JSON string to data")
        }
        
        
        
    }
    
    func onError(data: String) {
        self.voiceSearchDelegate.onError(data: data)
        VoiceInputWithoutUI.inProcess=false
    }
    
    func onStartRecording(isTrue: Bool) {
        self.voiceSearchDelegate.onRecordingStart(isTrue: isTrue)
        DispatchQueue.main.async {
            Logger.printLog(string:"Recording\(isTrue)")
        }
        
    }
    func onEndRecording(isTrue: Bool) {
        self.voiceSearchDelegate.onRecordingEnd(isTrue: isTrue)
        VoiceInputWithoutUI.inProcess=false
    }
    var apiKey:String
    var appId:String
    var domain:String
    var lang:String
    var voiceSearchDelegate:VoiceInputDelegates
    var sttStreaming:SttStreaming
    static var inProcess: Bool = false
    var isStreaming=false
    var logging:String
    
    init(apiKey: String, appId: String, domain: String, lang: String, voiceSearchDelegate: VoiceInputDelegates,logging:String,noInputTimeout:Int,silence:Int,timeout:Int) {
        self.apiKey = apiKey
        self.appId = appId
        self.domain = domain
        self.lang = lang
        self.logging=logging
        self.voiceSearchDelegate = voiceSearchDelegate
        sttStreaming=SttStreaming(appId: appId, apiKey: apiKey, domain:domain , lang:lang,logging: logging)
        sttStreaming.setSilence(silence: silence)
        sttStreaming.setNoInputTimeout(noInputTimeout: noInputTimeout)
        sttStreaming.setTimeout(timeout: timeout)
        sttStreaming.setDelegate(delegate: self)
    }
    
    func startStreaming()
    {   if(!VoiceInputWithoutUI.inProcess){
        isStreaming=true
        sttStreaming.startStreaming()
        VoiceInputWithoutUI.inProcess=true
    }
        
    }
    func stopStreamingForFinal()
    {    VoiceInputWithoutUI.inProcess=false
        if(isStreaming)
        {Logger.printLog(string: "Stoping Final")
            sttStreaming.stopStreamingForFinal()
            isStreaming=false
        }
    }
    func stopStreaming()
    {   VoiceInputWithoutUI.inProcess=false
        if(isStreaming)
        {   Logger.printLog(string: "Stoping")
            sttStreaming.stopStreaming()
            isStreaming=false
            
        }
        
        
    }
    
}
