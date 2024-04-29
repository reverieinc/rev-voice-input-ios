# Reverie Voice Input SDK iOS-Uikit 
 
This SDK helps in accurately converting speech into text using an API powered by Reverie's AI
technology. The solution will transcribe the speech in real-time in various Indian languages and
audio formats.

## Key Features

- **Accurate Speech-to-Text Conversion:** The Voice Input SDK ensures precise and reliable
  conversion of spoken words into text, leveraging the advanced AI technology developed by Reverie.

- **Minimalistic Integration:** Seamlessly integrate the SDK into your application with minimal
  effort, allowing you to focus on enhancing the user experience rather than grappling with complex
  integration processes.

- **Option to Use Bundled UI:** Enjoy the convenience of utilizing the bundled user interface,
  streamlining the integration process and offering a consistent and user-friendly experience within
  your application.


## API Reference

There are two constructors in the **RevVoiceInput** class. The first constructor accepts all parameters, allowing full customization. The second constructor accepts minimal parameters, assuming default values for language and domain.

There are two **startRecognitions()** methods in the **RevVoiceInput** class. The first method allows customization of language and domain for a specific call, while the second method uses default values for language and domain. Users can choose the constructor or method that best fits their needs based on whether they want to customize language and domain for the entire app flow or individual cases.


### Constructors

#### Constructor 1

| Parameter | Type   | Required | Default        | Description                     |
|-----------|--------|----------|----------------|---------------------------------|
| apiKey    | String | true     | -              | Api key given to the client     |
| appId     | String | true     | -              | App Id given to the client      |
| domain    | String | false    | -              | Domain of the voice Input      |
| Language  | String | false    |  -             | Language of voice Input        |
| Logging   | String | true     | -              | Logging of data required or not |

#### Constructor 2


| Parameter | Type   | Required | Default        | Description                     |
|-----------|--------|----------|----------------|---------------------------------|
| apiKey    | String | true     | -              | Api key given to the client     |
| appId     | String | true     | -              | App Id given to the client      |
| Logging   | String | true     | -              | Logging of data required or not |




### Supported Constants
Various constant values are provided in SDK for DOMAIN, LANGUAGES, and LOGGING parameters

#### Domain
1. Domain.VOICE_Input
2. Domain.GENERIC
3. Domain.BFSI

#### Languages
1.  Languages.ENGLISH
2.  Languages.HINDI

#### Logging
1.  Logging.TRUE - stores client’s audio and keeps transcript in logs.
2.  Logging.NO_AUDIO -  does not store client’s audio but keeps transcript in logs.
3.  Logging.NO_TRANSCRIPT - does not keep transcript in logs but stores client’s audio.
4.  Logging.FALSE - does not keep the client’s audio or the transcript in the log.



## Integrate the SDK in Your Application


1.Add the Swift Package using SPM and if using version lower than XCode 15 add Apple's  AVFAudio.framework without embedding
Note: Privacy Manifest has been added to the SDK as per Apple's Compliance.
### Optional Parameters
| Parameter | Type   | Description                                | Swift  code                         | 
|-----------|--------|--------------------------------------------|-----------------------------------|
| timeout   | int  | [Description](#Description-of-Parameters)  | `voiceInput.setTimeout(timeout:5)`   | 
| silence   | int  | [Description](#Description-of-Parameters)  | `voiceInput.setSilence(silence:1)`   | 
| noInputTimeout   | int  | [Description](#Description-of-Parameters)  | `    voiceInput.setNoInputTimeout(noInputTimeout: 6))`   | 

### Description of Parameters
1. **timeout**:The duration to keep a connection open between the application and the STT server.   
           Note: The default `"timeout = 15 seconds`", and the maximum time allowed = 180 seconds
2. **silence**:The time to determine when to end the connection automatically after detecting the silence after receiving the speech data. 
           Example:Consider `"silence = 15 seconds"` i.e., On passing the speech for 60 seconds, and if you remain silent, the connection will be open for the next 15 seconds and then will automatically get disconnected. 
           Note: The default silence= 1 second, and the maximum `"silence = 30 seconds"`.

### iOS UiKit Integration

 1. Prepare the constructor:

     ```sh
    //Preparing the constructor with valid API key and APP-ID
        let voiceInput=RevVoiceInput(apikey: String, appId: String)
    ```
    ```sh
    //Preparing the Constructor with  API-key , APP-ID , language,domain and logging
      let voiceInput=RevVoiceInput(apikey: String, appId: String, lang: String,  domain:Domain.VOICE_SEARCH,logging: Logging.TRUE)
    ```
 2. Add Listeners to ViewControllerClass
    
    ```sh
    class ViewController: UIViewController,VoiceInputDelegates {
    func onResult(data:VoiceInputResultData) {
       
    }
    func onError(data: String) {
      
        
    }
    func onRecordingStart(isTrue: Bool) {
        
    }
    func onRecordingEnd(isTrue: Bool) {
      }}
    ```

3. Start Voice Input
    ```sh
    voiceInput.startRecognition(on: self, voiceInputDelegates: self, isUIRequired: true)
    ```
    ```sh
    voiceInput.startRecognition(on: self //CurrentViewController, voiceInputDelegates: self, // listener implemented class
    isUIRequired: true, //whether the UI is required
    domain:Domain.VOICE_SEARCH,lang:Languages.ENGLISH)
    ```
4. Stop the Input for final Result
    ```sh
     voiceInput.finishInput()
    ```
5. Terminate Voice Input without final
    ```sh
     voiceInput.cancel()
     
    ```
 
6. (Optional) To Set the No Input Timeout
    ```sh
      voiceInput.setNoInputTimeout(noInputTimeout: 6)
   ```
7. (Optional) To Set the the TimeOut    
    ```sh
      voiceInput.setTimeout(timeout: 5)
    ```
8. (Optional) To Set the Silence
    ```sh
      voiceInput.setSilence(silence: 2)
    ```
9. (Optional) To Enable Logging(Logcat)
    ```sh
        Log.DEBUG=true
    ```     
License
-------
All Rights Reserved. Copyright 2024. Reverie Language Technologies Limited.(https://reverieinc.com/)

Reverie Voice Input SDK can be used according to the [Apache License, Version 2.0](LICENSE).
        
