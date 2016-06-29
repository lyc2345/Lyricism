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

class MusiXMatchApi: NSObject {
    
    typealias TrackHandler = (Void) -> Void
    
    private class func getTrackID(artist: String, track: String, completion: (success: Bool, trackID: NSNumber?) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.apikey,"q_artist": artist, "q_track": track]
        Alamofire.request(.GET, MusiXMatchURL.track.itself, parameters: parameter, encoding: .URL).responseJSON { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                
                if json["message"]["header"]["status_code"] == 200 {
                    
                    let track = Track.sharedTrack
                    
                    if let _ = track.getTrackPropertyAndValue(json), trackID = track.track_id {
                        print("track id: \(trackID)")
                        
                        return completion(success: true, trackID: trackID)
                    } else {
                        return completion(success: false, trackID: nil)
                    }
                    
                } else {
                    // handler error when query lyrics
                    return completion(success: false, trackID: nil)
                }
            } else {
                return completion(success: false, trackID: nil)
            }
        }
    }
    
    class func getTrackInfo(artist: String, track: String, completion: (success: Bool) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.apikey,"q_artist": artist, "q_track": track]
        Alamofire.request(.GET, MusiXMatchURL.track.itself, parameters: parameter, encoding: .URL).responseJSON { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                
                if json["message"]["header"]["status_code"] == 200 {
                    
                    let track = Track.sharedTrack
                    
                    if let _ = track.getTrackPropertyAndValue(json), trackID = track.track_id {
                        print("track id: \(trackID)")
                        
                        return completion(success: true)
                    } else {
                        return completion(success: false)
                    }
                    
                } else {
                    // handler error when query lyrics
                    return completion(success: false)
                }
            } else {
                return completion(success: false)
            }
        }
    }

    
    
    class func getLyricsNCoverURL(artist: String, track: String, completion: (success: Bool, lyrics: String?, coverURL: NSURL?) -> Void) {
        
        getTrackID(artist, track: track) { (success, trackID) in
            
            if success {
                
                let parameter: [String: AnyObject]? = ["apikey": MusiXMatchURL.apikey,"track_id": trackID!.stringValue]
                
                Alamofire.request(.GET, MusiXMatchURL.track.lyrics, parameters: parameter, encoding: .URL).responseJSON(completionHandler: { (response) in
                    
                    if response.result.isSuccess {
                        
                        let json = JSON(data: response.data!)
                        
                        if json["message"]["header"]["status_code"] == 200 {
                            
                            let trackJSON = JSON(data: response.data!)
                            Track.sharedTrack.getTrackPropertyAndValue(trackJSON)
                            
                            print("apilyrics: \(trackJSON["message"]["body"]["lyrics"]["lyrics_body"].string)")
                            
                            if let imageURLString = Track.sharedTrack.album_coverart_350x350, lyrics = trackJSON["message"]["body"]["lyrics"]["lyrics_body"].string {
                                completion(success: true, lyrics: lyrics, coverURL: NSURL(string: imageURLString)!)
                            }
                        }
                    } else {
                        completion(success: false, lyrics: nil, coverURL: nil)
                    }
                })
            } else {
                completion(success: false, lyrics: nil, coverURL: nil)
            }
            
        }
    }
    
    class func getSongInfo(artist: String, track: String, completion:(Void) -> JSON) {
        
        
        
    }
}

extension MusiXMatchApi {
    
    private struct MusiXMatchURL {
        
        private static let apikey = "65aa00d5f25b9dcc100deea97d14ce45"
        
        struct chart {
            static let artist = "http://api.musixmatch.com/ws/1.1/chart.aritsts.get?"
            static let tracks = "http://api.musixmatch.com/ws/1.1/chart.tracks.get?"
        }
        
        struct track {
            static let itself = "http://api.musixmatch.com/ws/1.1/track.search?"
            static let subtitle = "http://api.musixmatch.com/ws/1.1/track.subtitle.get?"
            static let lyrics = "http://api.musixmatch.com/ws/1.1/track.lyrics.get?"
            static let snippet = "http://api.musixmatch.com/ws/1.1/track.snippet.get?"
        }
        
        struct artist {
            
            static let itself = "http://api.musixmatch.com/ws/1.1/artist.get?"
            static let related = "http://api.musixmatch.com/ws/1.1/artist.related.get?"
        }
        
        struct album {
            static let itself = "http://api.musixmatch.com/ws/1.1/album.get?"
            static let tracks = "http://api.musixmatch.com/ws/1.1/album.tracks.get?"
        }
    }

}
