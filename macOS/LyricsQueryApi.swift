//
//  LyricsQueryApi.swift
//  macOS
//
//  Created by Stan Liu on 17/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import SWXMLHash
import JSONNeverDie

class LyricsQueryApi: NSObject {
    
    
    private struct MusiXMatchURL {
        
        private static let apikey = "65aa00d5f25b9dcc100deea97d14ce45"
        
        struct track {
            static let id = "http://api.musixmatch.com/ws/1.1/track.search?"
            static let subtitle = "http://api.musixmatch.com/ws/1.1/track.subtitle.get?"
            static let lyrics = "http://api.musixmatch.com/ws/1.1/track.lyrics.get?"
        }
        
        struct artist {
            
            static let itself = "http://api.musixmatch.com/ws/1.1/artist.get?"
        }
    }
    
    typealias TrackHandler = (Void) -> Void
    
    private class func getTrack(artist: String, track: String, completion: (Response<AnyObject, NSError>) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.apikey,"q_artist": artist, "q_track": track]
        Alamofire.request(.GET, MusiXMatchURL.track.id, parameters: parameter, encoding: .URL).responseJSON { (response) in
            completion(response)
        }
    }
    
    class func getLyrics(artist: String, track: String, completion: (Response<AnyObject, NSError>) -> Void) {
        
        getTrack(artist, track: track) { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                if json["message"]["header"]["status_code"] == 200 {
                    
                    print("track: \(json["message"]["body"]["track_list"])")
                    //json[0]["message"]["body"]["track_list"]["track"]["track_id"]
                    
                    
                    
                    
                }
            }
            
        }
    }
}
