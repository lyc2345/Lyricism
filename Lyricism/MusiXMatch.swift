//
//  MusiXMatch.swift
//  Lyricism
//
//  Created by Stan Liu on 30/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MusiXTrack {
    
    var artist: String
    var name: String
    var lyrics: String?
    var time: String
    var artwork: NSURL?
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

extension MusiXTrack: LyricsViewPresentable {
    
    var lvLyrics: String { return lyrics ?? "" }
    var lvArtworkURL: NSURL? { return artwork }
    var lvTime: String { return time }
    var lvArtistNTrack: (artist: String, trackName: String) { return (artist, name) }
}

struct MusicInfo {
  
  let has_lyrics: NSNumber!
  
  let track_share_url: String!
  let commontrack_vanity_id: String!
  let restricted: NSNumber!
  let track_spotify_id: String!
  let track_id: NSNumber!
  let artist_mbid: String!
  let artist_name: String!
  let album_coverart_800x800: String?
  let artist_id: NSNumber!
  let updated_time: String!
  let album_id: NSNumber!
  let album_coverart_100x100: String?
  let first_release_date: String!
  let album_coverart_350x350: String?
  let lyrics_id: NSNumber!
  let track_name: String!
  let track_length: NSNumber!
  let commontrack_id: NSNumber!
  let has_subtitles: NSNumber!
  
  let primary_genres: [String: AnyObject]?
  let secondary_genres: [String: AnyObject]?
  let music_genre_list: [AnyObject]?
  
  let music_genre_id: NSNumber?
  let music_genre_vanity: String?
  let music_genre_name: String?
  let music_genre_name_extended: String?
  
  let lyric: String?
  /*
  func getTrackPropertyAndValue(json: JSON) {
    
    let properties = self.propertyNames()
    for key in properties {
      
      if let stringValue = json["message"]["body"]["track"][key].string {
        
        //print("property: \(key), value: \(stringValue)")
        self.setValue(stringValue, forKey: key)
      } else if let numberValue = json["message"]["body"]["track"][key].int {
        
        //print("property: \(key), value: \(numberValue)")
        self.setValue(numberValue, forKey: key)
      } else {
        
        //primary_genre
        if let _ = json["message"]["body"]["track"]["primary_genres"].dictionary {
          //print("property: \(key), value: \(primary_genres)")
          
        }
        if let genreStringValue = json["message"]["body"]["track"]["primary_genres"]["music_genre_list"][0]["music_genre"][key].string {
          //print("property: \(key), value: \(genreStringValue)")
          self.setValue(genreStringValue, forKey: key)
          
        }
        if let genreNumberValue = json["message"]["body"]["track"]["primary_genres"]["music_genre_list"][0]["music_genre"][key].number {
          //print("property: \(key), value: \(genreNumberValue)")
          self.setValue(genreNumberValue, forKey: key)
        }
      }
    }
  }*/

}

