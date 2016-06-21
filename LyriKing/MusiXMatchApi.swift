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
    
    private class func getTrack(artist: String, track: String, completion: (Response<AnyObject, NSError>) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.apikey,"q_artist": artist, "q_track": track]
        Alamofire.request(.GET, MusiXMatchURL.track.itself, parameters: parameter, encoding: .URL).responseJSON { (response) in
            completion(response)
        }
    }
    
    class func getLyrics(artist: String, track: String, completion: (Response<AnyObject, NSError>) -> Void) {
        
        getTrack(artist, track: track) { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                
                if json["message"]["header"]["status_code"] == 200 {
                    
                    let track = Track.sharedTrack
                    
                    if let trackDetail = track.getTrackPropertyAndValue(json) {
                        print("track id: \(track.track_id)")
                        
                        let parameter = ["apikey": MusiXMatchURL.apikey,"track_id": trackDetail.track_id]
                        
                        Alamofire.request(.GET, MusiXMatchURL.track.lyrics, parameters: parameter, encoding: .URL).responseJSON(completionHandler: { (response) in
                            
                            completion(response)
                        })
                    }
                } else {
                    // handler error when query lyrics
                }
            }
        }
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
