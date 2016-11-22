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
    
	private class func matchSongUtimatly(_ artist: String, trackName: String, completion: @escaping (_ success: Bool, _ trackID: Int?) -> Void) {
    
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
			
			guard let stringOFJSON = json["message"]["body"]["track"].rawString(),
				let artistInformation = Artist(JSONString: stringOFJSON),
				let albumInformation = Album(JSONString: stringOFJSON),
				let trackInformation = Track(JSONString: stringOFJSON) else {
					
					return completion(false, nil)
			}
			albumInformation.artist = artistInformation
			trackInformation.album = albumInformation
			trackInformation.artist = artistInformation
			
			SFRealm.update(artistInformation)
			SFRealm.update(albumInformation)
			SFRealm.update(trackInformation)
			
      return completion(true, trackInformation.id)
    }
  }
  
    // 這個超弱 有些會搜尋不到
//    class func searchTrackID(_ track: PlayerTrack, completion: @escaping (_ success: Bool, _ trackID: NSNumber?) -> Void) {
//        
//        let parameter = ["apikey": MusiXMatchURL.Apikey,"q_artist": track.artist, "q_track": track.name]
//        
//        Alamofire.request(MusiXMatchURL.track.itself, parameters: parameter).responseJSON() { (response) in
//            
//            if response.result.isSuccess {
//                
//                let json = JSON(data: response.data!)
//                if json["message"]["header"]["status_code"] == 200 {
//                  
//                  weak var info = Player.sharedPlayer.info
//                    info?.getTrackPropertyAndValue(json)
//                    
//                    if let trackID = json["message"]["body"]["track_list"][0]["track"]["track_id"].rawValue as? NSNumber {
//                        //print("track id: \(trackID)")
//                        return completion(true, trackID)
//                    }
//                }
//            }
//            return completion(false, nil)
//        }
//    }
	
	class func searchLyrics(_ artist: String, trackName: String, completion: @escaping (_ success: Bool, _ lyric: String?, _ data: Data?) -> Void) {
    
    matchSongUtimatly(artist, trackName: trackName) { (success, trackID) in
      
      if let trackID = trackID, success == true {
				#if true
        let parameter: [String: AnyObject]? = ["apikey": MusiXMatchURL.Apikey as AnyObject,"track_id": trackID as AnyObject]
				
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
					
					guard let stringOfJSON = json["message"]["body"]["lyrics"].rawString(),
						let lyricInformation = Lyric(JSONString: stringOfJSON) else {
						return completion(false, nil, nil)
					}
					
					guard let track = SFRealm.query(id: trackID, t: Track.self)?.first else {
						return completion(false, nil, nil)
					}
					lyricInformation.name = track.name
					SFRealm.update(lyricInformation)
					
					SFRealm.update {
						
						track.lyric = lyricInformation
					}

					return completion(true, lyricInformation.text, track.album?.artwork)
        }
				#endif
      }
    }
  }
}
