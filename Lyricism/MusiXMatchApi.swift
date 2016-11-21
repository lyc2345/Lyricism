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
import RealmSwift


enum MusiXMatchURL {
    
    static let Apikey = "65aa00d5f25b9dcc100deea97d14ce45"
    
    enum chart {
        static let artist = "http://api.musixmatch.com/ws/1.1/chart.aritsts.get?"
        static let tracks = "http://api.musixmatch.com/ws/1.1/chart.tracks.get?"
    }
    
    enum track {
        static let itself = "http://api.musixmatch.com/ws/1.1/track.search?"
        static let subtitle = "http://api.musixmatch.com/ws/1.1/track.subtitle.get?"
        static let lyrics = "http://api.musixmatch.com/ws/1.1/track.lyrics.get?"
        static let snippet = "http://api.musixmatch.com/ws/1.1/track.snippet.get?"
    }
    
    enum artist {
        
        static let itself = "http://api.musixmatch.com/ws/1.1/artist.get?"
        static let related = "http://api.musixmatch.com/ws/1.1/artist.related.get?"
    }
    
    enum album {
        static let itself = "http://api.musixmatch.com/ws/1.1/album.get?"
        static let tracks = "http://api.musixmatch.com/ws/1.1/album.tracks.get?"
    }
    
    enum matchmore {
        static let itself = "http://api.musixmatch.com/ws/1.1/matcher.track.get?"
    }
}

class MusiXMatchApi {
    
  class func matchSongUtimatly(_ artist: String, trackName: String, completion: @escaping (_ success: Bool, _ info: Info?) -> Void) {
    
    let parameter = ["apikey": MusiXMatchURL.Apikey, "q_track": trackName, "q_artist": artist]
    
		Alamofire.request(MusiXMatchURL.matchmore.itself, parameters: parameter).responseJSON() { (response) in
      
      guard response.result.isSuccess else {
        
        return
      }
      
      let json = JSON(data: response.data!)
      
      guard json["message"]["header"]["status_code"] == 200 else {
        print("json status code != 200,")
        return completion(false, nil)
      }
      
      weak var info = Player.sharedPlayer.info
      info?.getTrackPropertyAndValue(json)
      return completion(true, info)
    }
  }
  
    // 這個超弱 有些會搜尋不到
    class func searchTrackID(_ track: PlayerTrack, completion: @escaping (_ success: Bool, _ trackID: NSNumber?) -> Void) {
        
        let parameter = ["apikey": MusiXMatchURL.Apikey,"q_artist": track.artist, "q_track": track.name]
        
        Alamofire.request(MusiXMatchURL.track.itself, parameters: parameter).responseJSON() { (response) in
            
            if response.result.isSuccess {
                
                let json = JSON(data: response.data!)
                if json["message"]["header"]["status_code"] == 200 {
                  
                  weak var info = Player.sharedPlayer.info
                    info?.getTrackPropertyAndValue(json)
                    
                    if let trackID = json["message"]["body"]["track_list"][0]["track"]["track_id"].rawValue as? NSNumber {
                        //print("track id: \(trackID)")
                        return completion(true, trackID)
                    }
                }
            }
            return completion(false, nil)
        }
    }
        
  class func searchLyrics(_ artist: String, trackName: String, completion: @escaping (_ success: Bool, _ info: Info?, _ lyric: String?) -> Void) {
    
    matchSongUtimatly(artist, trackName: trackName) { (success, info) in
      
      if let info = info, success == true {
        
        let parameter: [String: AnyObject]? = ["apikey": MusiXMatchURL.Apikey as AnyObject,"track_id": info.track_id]
				
				Alamofire.request(MusiXMatchURL.track.lyrics, parameters: parameter).responseJSON() { (response) in
          
          guard response.result.isSuccess else {
            
            print("searchLyrics result is failure")
            return completion(false, nil, nil)
          }
          
          let json = JSON(data: response.data!)
          
          guard json["message"]["header"]["status_code"] == 200 else {
            print("json status code != 200")
            return completion(false, nil, nil)
          }
          
          guard let lyric = json["message"]["body"]["lyrics"]["lyrics_body"].string else {
            
            return
          }
          let lyric_id = json["message"]["body"]["lyrics"]["lyrics_id"].stringValue
          //let l = MusiXLyric(id: NSString(string: lyric_id).integerValue, name: info.track_name, text: lyric)
          return completion(true, info, lyric)
					
					
					
					let t = Track()
					t.id = info.track_id.intValue
					t.name = info.track_name
					// TODO: edit here
					t.time = Time(allTimeString: "2:21").timeInterval
					//t.time = Time(allTimeString: presenter.lvTime).timeInterval
					t.album_name = info.album_name
					t.lyric_id = info.lyrics_id.intValue
					t.album_id = info.album_id.intValue
					t.spotify_id = info.track_spotify_id.intValue
					t.artist_id = info.artist_id.intValue
					SFRealm.update(t)
					
					let a = Album()
					a.id = info.album_id.intValue
					a.name = info.album_name
					a.artist_id = info.artist_id.intValue
					a.url_str = info.album_coverart_350x350!
					
					do {
					let url = URL(string: a.url_str)
					a.artwork = try Data(contentsOf: url!)
					
					a.tracks.value = info.track_id.intValue
					SFRealm.update(a)
					} catch {
						
					}
					
					let art = Artist()
					art.id = info.artist_id.intValue
					art.name = info.artist_name
					SFRealm.update(art)
					
					let l = Lyric()
					l.id = info.lyrics_id.intValue
					l.name = info.track_name
					l.text = lyric
					SFRealm.update(l)

        }
      }
    }
  }
	
    class func searchArtwork(_ completion: (_ success: Bool, _ url: URL?) -> Void) {
      
      guard let urlString = Player.sharedPlayer.info?.album_coverart_350x350 else {
          return completion(false, nil)
      }
      return completion(true, URL(string: urlString))
    }
}
