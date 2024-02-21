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
import UIKit

/// Bottomsheet VoiceSearch View UI class (View controller for the Ui that Popups)
class VoiceSearchUiBottomSheet: UIViewController ,StreamingDelegate{
	public func onStartRecording(isTrue: Bool) {
		Logger.printLog(string:"Recording start"+String(isTrue))
		listeningLabel.text="Listening..."
		self.progressCircleView.isHidden=false
		
	}
	
	public func onEndRecording(isTrue: Bool) {
		Logger.printLog(string:"Recording End"+String(isTrue))
		listeningLabel.text=""
		self.progressCircleView.isHidden=true
	}
	
	public func onResult(data: String) {
		DispatchQueue.main.async { [self] in
			Logger.printLog(string:data)
			isGotResponse=true
			
			// output=data
			if let str = convertToDictionary(text: data), let displayText = str["display_text"] as? String, displayText != "" {
				self.outputLabel.text=displayText
			}
			
			if let str = convertToDictionary(text: data), let displayText = str["display_text"] as? String, displayText != "", let final = str["final"] as? Bool, final {
				if(final)
				{if let jsonData = data.data(using: .utf8) {
					do {
						
						let person = try JSONDecoder().decode(VoiceInputResultData.self, from: jsonData)
						Logger.printLog(string:person)
						
						DispatchQueue.main.async{
							self.voiceSearchResultDelegates.onResult(data: person)
							self.dismiss(animated: true)
						}
					} catch {
						Logger.printLog(string:"Error decoding JSON: \(error)")
					}
				} else {
					Logger.printLog(string:"Error converting JSON string to data")
				}
					
					
				}
				
			}
			
		}
		
	}
	
	public func onError(data: String) {
		
		DispatchQueue.main.async {
			
			Logger.printLog(string:data)
			Logger.printLog(string: "Dismissing")
			DispatchQueue.main.async{
				self.voiceSearchResultDelegates.onError(data: data)
				self.dismiss(animated: true)
			}
			
			
			
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
	
	var topText: String=""
	var bottomText: String=Constants.bottomLabel
	private  var apiKey:String = ""
	private var appID:String = ""
	private var lang:String = ""
	private var domain:String = ""
	private var voiceSearchResultDelegates:VoiceInputDelegates
	private var sttStreaming:SttStreaming
	private var logging:String
	private var isGotResponse=false
	init( apiKey: String, appID: String, lang: String, domain: String, voiceSearchResultDelegates: VoiceInputDelegates,logging:String) {
		self.apiKey = apiKey
		self.appID = appID
		self.lang = lang
		self.domain = domain
		self.voiceSearchResultDelegates = voiceSearchResultDelegates
		self.logging=logging
		sttStreaming=SttStreaming(appId: appID, apiKey: apiKey, domain: domain, lang: lang,logging: logging)
		super.init(nibName: nil, bundle: nil)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	let contentView: UIView = {
		let view = UIView()
		view.backgroundColor = Constants.backgroundColor
		return view
	}()
	
	let progressCircleView: CircularProgressBarView = {
		let view = CircularProgressBarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()
	
	let outputLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.textColor = .white
		label.numberOfLines = 2 // Set the number of lines to 2
		label.lineBreakMode = .byTruncatingTail 
		return label
	}()
	
	let listeningLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.textColor = .white
		label.text="Listening..."
		return label
	}()
	let micImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "mic.fill"))
		imageView.tintColor = .red
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled=true
		
		//  setupUI()
		return imageView
		
	}()
	let closeButton: UIButton = {
		// Logger.printLog(string:"close")
		let button = UIButton()
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.tintColor = .white
		button.contentMode = .center
		button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		return button
	}()
	let reverieTitleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = .white
		return label
	}()
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		setupUI();
		sttStreaming.setDelegate(delegate: self)
		sttStreaming.startStreaming()
		
		
		
		
		//  progressCircleView.animateRotation()
	}
	@objc func micGestureMethod(_ sender: UITapGestureRecognizer) {
		outputLabel.text=""
		listeningLabel.text=""
		if(!self.progressCircleView.isHidden)
		{	Logger.printLog(string: "1:Case")
			sttStreaming.stopStreamingForFinal()
			self.progressCircleView.isHidden=true
		}
		else{
			Logger.printLog(string: "2:Case")
			self.progressCircleView.isHidden=false
			sttStreaming.startStreaming()
		}
	}
	@objc func viewTapGesture(_ sender: UITapGestureRecognizer) {
		
		self.dismiss(animated: true)
		sttStreaming.stopStreaming()
	
		
	}/*
	func isPortrait() -> Bool {
		let orientation = UIDevice.current.orientation
		return orientation == .portrait || orientation == .portraitUpsideDown
	}
	
	func isLandscape() -> Bool {
		let orientation = UIDevice.current.orientation
		return orientation == .landscapeLeft || orientation == .landscapeRight
	}*/
	func setupUI() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(micGestureMethod(_:)))
	//	let screenSize:CGRect = UIScreen.main.bounds
		
		// Add the gesture recognizer to your view
		self.micImageView.isUserInteractionEnabled=true
		self.outputLabel.isUserInteractionEnabled=true
		self.micImageView.addGestureRecognizer(tapGesture)
		view.backgroundColor = .clear
		view.isUserInteractionEnabled=true
		let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapGesture(_:)))
		view.addGestureRecognizer(backgroundTapGesture)
		view.addSubview(contentView)
		contentView.addSubview(progressCircleView)
		
		contentView.addSubview(outputLabel)
		contentView.addSubview(closeButton)
		
		//  contentView.addSubview(micContainerView)
		contentView.addSubview(reverieTitleLabel)
		
		contentView.addSubview(micImageView)
		contentView.addSubview(listeningLabel)
		
		
		outputLabel.text = topText
		reverieTitleLabel.text = bottomText
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		 
		/// Handling Larger Orientation
		let orientation = UIDevice.current.orientation
			Logger.printLog(string:orientation.rawValue)
			if UIScreen.main.bounds.size.width <= 320
			{
				contentView.heightAnchor.constraint(equalToConstant: 280).isActive = true}
			else{
				
				contentView.heightAnchor.constraint(equalToConstant: 300).isActive = true}
		
		
		// Apply corner radius
		contentView.layer.cornerRadius = 30
		
		
		contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		contentView.layer.masksToBounds = true
		
		outputLabel.translatesAutoresizingMaskIntoConstraints = false
		outputLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
		outputLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
		outputLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true// Adjust top margin
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
		closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
		micImageView.translatesAutoresizingMaskIntoConstraints = false
		micImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		micImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		micImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
		micImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		progressCircleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		progressCircleView.centerYAnchor.constraint(equalTo:  contentView.centerYAnchor).isActive = true
		progressCircleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
		progressCircleView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		
		reverieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		reverieTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		reverieTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		reverieTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
		
		listeningLabel.translatesAutoresizingMaskIntoConstraints = false
		listeningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		listeningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		listeningLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50).isActive = true
		startContinuousRotation(view: progressCircleView)
	}
	
	@objc func micImageViewTapped() {
		// Implement the action to be performed when the mic image is tapped
		
		Logger.printLog(string:"Mic image tapped!")
	}
	/// Start Rotating Animation
	func startContinuousRotation(view: UIView) {
		let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		rotationAnimation.values = [0, 2 * CGFloat.pi]
		rotationAnimation.timingFunctions = [CAMediaTimingFunction(name: .linear)]
		rotationAnimation.duration = 1.0
		rotationAnimation.repeatCount = .infinity
		
		view.layer.add(rotationAnimation, forKey: "continuousRotation")
	}
	
	@objc func closeButtonTapped() {
		// Implement the action to close the bottom popup
		Logger.printLog(string:"Tap")
		sttStreaming.stopStreaming()
		dismiss(animated: true, completion: nil)
	}
}
/// Circular Progress VIew
class CircularProgressBarView: UIView {
	private let shapeLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.strokeColor = UIColor.white.cgColor
		layer.fillColor = UIColor.clear.cgColor
		layer.lineWidth = 10
		return layer
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupUI()
	}
	
	private func setupUI() {
		layer.addSublayer(shapeLayer)
		animateRotation()
	}
	
	public func animateRotation() {
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
		rotationAnimation.toValue = 3 * Double.pi / 2 // 270 degrees
		rotationAnimation.duration = 1
		rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
		shapeLayer.add(rotationAnimation, forKey: nil)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		updateCircularPath()
	}
	
	private func updateCircularPath() {
		let radius = min(bounds.width, bounds.height) / 2 - shapeLayer.lineWidth / 2
		let startAngle: CGFloat = -CGFloat.pi / 2
		let endAngle: CGFloat = startAngle + 3 * CGFloat.pi / 2 // 270 degrees
		
		let circularPath = UIBezierPath(
			arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
			radius: radius,
			startAngle: startAngle,
			endAngle: endAngle,
			clockwise: true
		)
		shapeLayer.path = circularPath.cgPath
	}
}
