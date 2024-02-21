
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
import UIKit
struct Constants{
    
    static let STREAM_URL="wss://revapi.reverieinc.com/stream"
    //Warning messages
    static let WARNING_NO_INTERNET = "No Internet Connection."
    
    static let bottomLabel = "Powered By Reverie"
    
    static var backgroundColor = UIColor(red: 24/255.0, green: 29/255.0, blue: 34/255.0, alpha: 1.0)
  
    
}
struct JsonLabels
{
    static let id = "id"
    static let success = "success"
    static let text = "text"
    static let final = "final"
    static let confidence = "confidence"
    static let cause = "cause"
    static let display_text = "display_text"
    
    
}
/// Constants  for Various Voice Search Domains
public struct Domain{
    
    
    public static let VOICE_SEARCH = "voice_search"
    public static let GENERIC="generic"
    public static let BFSI="bfsi"
    public static let APP_SEARCH="app_search"
    
}
///This struct  is Constant class for Various Logging Parameters
/// Logging.TRUE - stores client’s audio and keeps transcript in logs.
///. Logging.NO_AUDIO - does not store client’s audio but keeps transcript in logs.
///. Logging.NO_TRANSCRIPT - does not keep transcript in logs but stores client’s audio.
///. Logging.FALSE - does not keep the client’s audio or the transcript in th
public struct Logging{
    
    public static let TRUE="true"
    public static let FALSE="false"
    public static let NO_AUDIO="no_audio"
    public static let NO_TRANSCRIPT="no_transcript"
    
    
}

/// This Struct Contains Language Code for Streaming
public struct Languages{
    public static let HINDI = "hi"
    public static let ASSAMESE = "as"
    public static let BENGALI = "bn"
    public static let GUJARATI = "gu"
    public static let KANNADA = "kn"
    public static let MALAYALAM = "ml"
    public static let MARATHI = "mr"
    public static let ODIA = "or"
    public static let PUNJABI = "pa"
    public static let TAMIL = "ta"
    public static let TELUGU = "te"
    public static let ENGLISH = "en"
    
    
    
}
