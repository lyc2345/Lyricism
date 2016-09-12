//
//  Track.swift
//  LyriKing
//
//  Created by Stan Liu on 01/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class MAlbum: Object {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  dynamic var artist_id: Int = 0 //fk
  dynamic var url_str: String = ""
  dynamic var artwork: NSData?
  var tracks: RealmOptional<Int> = RealmOptional<Int>()
  
  override static func primaryKey() -> String? {
    
    return "id"
  }
}

class MTrack: Object {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  dynamic var time: Int = 0
  dynamic var album_name: String = ""
  
  dynamic var lyric_id: Int = 0 //fk
  dynamic var album_id: Int = 0 //fk
  dynamic var spotify_id: Int = 0 //fk
  dynamic var artist_id: Int = 0 //fk
  
  override static func primaryKey() -> String? {
    
    return "id"
  }
}

class MArtist: Object {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  
  override static func primaryKey() -> String? {
    
    return "id"
  }
}

class MLyric: Object {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  dynamic var text: String = ""
  
  override static func primaryKey() -> String? {
    
    return "id"
  }
}


























class Track: NSObject {
  
    static let sharedTrack: Track = Track()
    
    override init() {
        info = Info()
    }
    
    var info: Info!
}

protocol Propertyable {
  
}

extension Propertyable {
  /*
  func propertyNames() -> [String] {
    
    var results: [String] = []
    // retrieve the properties via the class_copyPropertyList function
    var count: UInt32 = 0
    let myClass: AnyClass = self.classForCoder
    let properties = class_copyPropertyList(myClass, &count)
    
    // iterate each objc_property_t struct
    for i: UInt32 in 0 ..< count {
      
      let property = properties[Int(i)]
      // retrieve the property name by calling property_getName function
      let cname = property_getName(property)
      // convert the c string into a swift string
      let name = String.fromCString(cname)
      results.append(name!)
    }
    
    // release objc_property_t struct
    free(properties)
    
    return results
  }
*/
}

class Info: NSObject {
  
    var has_lyrics: NSNumber!
  
    var track_share_url: String!
    var commontrack_vanity_id: NSNumber!
    var restricted: NSNumber!
    var track_spotify_id: NSNumber!
    var track_id: NSNumber!
    var artist_mbid: NSNumber!
    var artist_name: String!
    var album_coverart_800x800: String?
    var artist_id: NSNumber!
    var updated_time: String!
    var album_id: NSNumber!
    var album_name: String! 
    var album_coverart_100x100: String?
    var first_release_date: String!
    var album_coverart_350x350: String?
    var lyrics_id: NSNumber!
    var track_name: String!
    var track_length: NSNumber!
    var commontrack_id: NSNumber!
    var has_subtitles: NSNumber!
    
    var primary_genres: [String: AnyObject]?
    var secondary_genres: [String: AnyObject]?
    var music_genre_list: [AnyObject]?
    
    var music_genre_id: NSNumber?
    var music_genre_vanity: String?
    var music_genre_name: String?
    var music_genre_name_extended: String?
    
    var lyric: String?
    
    
    func getCurrentTrackID() {
        //TODO: Clean up this code after testing
        let iTunes = AppDelegate.sharedDelegate.iTunes
        
        guard let artist = iTunes.currentTrack?.artist, name = iTunes.currentTrack?.name, time = iTunes.currentTrack?.time else {
            
            return
        }
      let track = PlayerTrack(artist: artist, name: name, time: time)
        MusiXMatchApi.searchTrackID(track) { (success, trackID) in
            //
        }
    }
    
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
    }
  
  func saveInRealm() {
    
    let track = MTrack()
    track.id = self.track_id.integerValue
    track.name = self.track_name
    track.lyric_id = self.lyrics_id.integerValue
    track.album_id = self.album_id.integerValue
    track.spotify_id = self.track_spotify_id.integerValue
    track.artist_id = self.artist_id.integerValue
    
    let artist = MArtist()
    artist.id = self.artist_id.integerValue
    artist.name = self.artist_name
    
    let album = MAlbum()
    album.id = self.album_id.integerValue
    if let url = self.album_coverart_350x350 {
      album.url_str = url
      album.artwork = NSData(contentsOfURL: NSURL(string: url)!)
    }
    album.artist_id = self.artist_id.integerValue
    
    let realm = try! Realm()
    
    try! realm.write {
      realm.add([track, artist, album])
    }
  }
}



