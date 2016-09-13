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
import RealmSwift


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

class MusiXMatchApi {
    
  class func matchSongUtimatly(artist: String, trackName: String, completion: (success: Bool, info: Info?) -> Void) {
    
    let parameter = ["apikey": MusiXMatchURL.Apikey.rawValue, "q_track": trackName, "q_artist": artist]
    
    Alamofire.request(.GET, MusiXMatchURL.MatchMore.itself.rawValue, parameters: parameter, encoding: .URL).responseJSON { (response) in
      
      guard response.result.isSuccess else {
        
        return
      }
      
      let json = JSON(data: response.data!)
      
      guard json["message"]["header"]["status_code"] == 200 else {
        print("json status code != 200,")
        return completion(success: false, info: nil)
      }
      
      weak var info = Player.sharedPlayer.info
      info?.getTrackPropertyAndValue(json)
      return completion(success: true, info: info)
    }
  }
  
    // 這個超弱 有些會搜尋不到
    class func searchTrackID(track: PlayerTrack, completion: (success: Bool, trackID: NSNumber?) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.Apikey.rawValue,"q_artist": track.artist, "q_track": track.name]
        
        Alamofire.request(.GET, MusiXMatchURL.track.itself.rawValue, parameters: parameter, encoding: .URL).responseJSON { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                if json["message"]["header"]["status_code"] == 200 {
                  
                  weak var info = Player.sharedPlayer.info
                    info?.getTrackPropertyAndValue(json)
                    
                    if let trackID = json["message"]["body"]["track_list"][0]["track"]["track_id"].rawValue as? NSNumber {
                        //print("track id: \(trackID)")
                        return completion(success: true, trackID: trackID)
                    }
                }
            }
            return completion(success: false, trackID: nil)
        }
    }
        
  class func searchLyrics(artist: String, trackName: String, completion: (success: Bool, info: Info?, lyric: MusiXLyric?) -> Void) {
    
    matchSongUtimatly(artist, trackName: trackName) { (success, info) in
      
      if let info = info where success == true {
        
        let parameter: [String: AnyObject]? = ["apikey": MusiXMatchURL.Apikey.rawValue,"track_id": info.track_id]
        
        Alamofire.request(.GET, MusiXMatchURL.track.lyrics.rawValue, parameters: parameter, encoding: .URL).responseJSON(completionHandler: { (response) in
          
          guard response.result.isSuccess else {
            
            print("searchLyrics result is failure")
            return completion(success: false, info: nil, lyric: nil)
          }
          
          let json = JSON(data: response.data!)
          
          guard json["message"]["header"]["status_code"] == 200 else {
            print("json status code != 200")
            return completion(success: false, info: nil, lyric: nil)
          }
          
          guard let lyric = json["message"]["body"]["lyrics"]["lyrics_body"].string else {
            
            return
          }
          let lyric_id = json["message"]["body"]["lyrics"]["lyrics_id"].stringValue
          let l = MusiXLyric(id: NSString(string: lyric_id).integerValue, name: info.track_name, text: lyric)
          return completion(success: true, info: info, lyric: l)
        })
      }
    }
  }
  
    class func searchArtwork(completion: (success: Bool, url: NSURL?) -> Void) {
      
      guard let urlString = Player.sharedPlayer.info?.album_coverart_350x350 else {
          return completion(success: false, url: nil)
      }
      return completion(success: true, url: NSURL(string: urlString))
    }
}
