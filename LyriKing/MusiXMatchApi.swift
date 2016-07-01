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


struct MusiXTrack {
    
    var artist: String
    var name: String
    var lyrics: String?
    var time: String
}

struct MusiXAlbum {
    var artist: String
    var tracks: [MusiXTrack]
    var composer: String
}

struct MusiXArtist {
    
    var name: String
    var albums: [MusiXAlbum]
}

protocol MusiXMatchTrack {
    
    func searchTrackID(track: MusiXTrack!, completion:(success: Bool, trackID: NSNumber?) -> Void)
}

protocol MusiXMatchArtist {
    
    
}

protocol MusiXMatchAlbum {
    
    
}

protocol MusiXMatchMatcher {
    
    //func matchSongPrimer(track: MusiXTrack, completion:(Void) -> Void)
    //func matchSongMoreDifficult(track: MusiXTrack, completion: (Void) -> Void)
    func matchSongUtimatly(track: MusiXTrack, completion: (success: Bool, trackID: NSNumber?) -> Void)
    
}

class MusiXMatchApi {
    
    struct ReceiveD {
        static var trackID: NSNumber?
        static var trackArtworkURLString: String?
    }
    
    class func matchSongUtimatly(track: MusiXTrack, completion: (success: Bool, trackID: NSNumber?) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.Apikey.rawValue, "q_track": track.name, "q_artist": track.artist]
        Alamofire.request(.GET, MusiXMatchURL.MatchMore.itself.rawValue, parameters: parameter, encoding: .URL).responseJSON { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                if json["message"]["header"]["status_code"] == 200 {
                    
                    if let trackID = json["message"]["body"]["track"]["track_id"].rawValue as? NSNumber {
                        
                        let track = Track.sharedTrack
                        track.getTrackPropertyAndValue(json)
                        return completion(success: true, trackID: trackID)
                    }
                }
                return completion(success: false, trackID: nil)
            }
        }
    }
    
    class func searchTrackID(track: MusiXTrack, completion: (success: Bool, trackID: NSNumber?) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.Apikey.rawValue,"q_artist": track.artist, "q_track": track.name]
        Alamofire.request(.GET, MusiXMatchURL.track.itself.rawValue, parameters: parameter, encoding: .URL).responseJSON { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                
                if json["message"]["header"]["status_code"] == 200 {
                    
                    let track = Track.sharedTrack
                    track.getTrackPropertyAndValue(json)
                    
                    if let trackID = json["message"]["body"]["track_list"][0]["track"]["track_id"].rawValue as? NSNumber {
                        print("track id: \(trackID)")
                        self.ReceiveD.trackArtworkURLString = json["message"]["body"]["track_list"][0]["track"]["album_coverart_350x350"].string
                        return completion(success: true, trackID: trackID)
                    }
                }
            }
            return completion(success: false, trackID: nil)
        }
    }
        
    class func searchLyrics(track: MusiXTrack, completion: (success: Bool, lyrics: String?) -> Void) {
        
        matchSongUtimatly(track) { (success, trackID) in
            
            if success {
                
                let parameter: [String: AnyObject]? = ["apikey": MusiXMatchURL.Apikey.rawValue,"track_id": trackID!.stringValue]
                Alamofire.request(.GET, MusiXMatchURL.track.lyrics.rawValue, parameters: parameter, encoding: .URL).responseJSON(completionHandler: { (response) in
                    
                    if response.result.isSuccess {
                        
                        let json = JSON(data: response.data!)
                        if json["message"]["header"]["status_code"] == 200 {
                            
                            // TODO:
                            if let lyrics = json["message"]["body"]["lyrics"]["lyrics_body"].string {
                                
                                print("apilyrics: \(json["message"]["body"]["lyrics"]["lyrics_body"].string)")
                                return completion(success: true, lyrics: lyrics)
                            }
                        }
                    }
                    return completion(success: false, lyrics: nil)
                })
            }
        }
    }
    
    class func searchArtwork(track: MusiXTrack, completion: (success: Bool, url: NSURL?) -> Void) {
        if let urlString = Track.sharedTrack.album_coverart_350x350 {
            return completion(success: true, url: NSURL(string: urlString))
        } else {
            return completion(success: false, url: nil)
        }
    }
}



enum MusiXMatchURL: String {
    
    case Apikey = "65aa00d5f25b9dcc100deea97d14ce45"
    
    enum Chart: String {
        case artist = "http://api.musixmatch.com/ws/1.1/chart.aritsts.get?"
        case tracks = "http://api.musixmatch.com/ws/1.1/chart.tracks.get?"
    }
    
    enum track: String {
        case itself = "http://api.musixmatch.com/ws/1.1/track.search?"
        case subtitle = "http://api.musixmatch.com/ws/1.1/track.subtitle.get?"
        case lyrics = "http://api.musixmatch.com/ws/1.1/track.lyrics.get?"
        case snippet = "http://api.musixmatch.com/ws/1.1/track.snippet.get?"
    }
    
    enum artist: String {
        
        case itself = "http://api.musixmatch.com/ws/1.1/artist.get?"
        case related = "http://api.musixmatch.com/ws/1.1/artist.related.get?"
    }
    
    enum album: String {
        case itself = "http://api.musixmatch.com/ws/1.1/album.get?"
        case tracks = "http://api.musixmatch.com/ws/1.1/album.tracks.get?"
    }
    
    enum MatchMore: String {
        case itself = "http://api.musixmatch.com/ws/1.1/matcher.track.get?"
    }
}

extension MusiXMatchApi {
    
    private struct MusiXMatchURLYY {
        
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
