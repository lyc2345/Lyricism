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
import ObjectMapper

class Album: Object, Mappable {
	
	dynamic var id: Int = 0 //pk
	dynamic var name: String = ""
	dynamic var url_str: String = ""
	dynamic var artwork: Data?
	var artist: Artist?
	var tracks: List<Track>?
	
	override static func primaryKey() -> String? {
		
		return "id"
	}
	
	required convenience init?(map: Map) {
		self.init(map: map)
		
	}
	func mapping(map: Map) {
		do {
			id  <- map["album_id"]
			name <- map["album_name"]
			url_str <- map["album_coverart_350x350"]
			artwork = try Data(contentsOf: URL(string: url_str)!)
			
		} catch {
			
		}
	}
}

class Track: Object, Mappable {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  dynamic var time: Int = 0
  weak dynamic var album: Album?
  
  dynamic var lyric_id: Int = 0 //fk
  dynamic var album_id: Int = 0 //fk
  dynamic var spotify_id: Int = 0 //fk
	weak dynamic var artist: Artist?
	
  override static func primaryKey() -> String? {
    
    return "id"
  }
	required convenience init?(map: Map) {
		self.init()
		
	}
	func mapping(map: Map) {
		id <- map["track_id"]
		name <- map["track_name"]
		lyric_id <- map["lyric_id"]
		album_id <- map["album_id"]
		spotify_id <- map["track_spotify_id"]
	}
}

class Artist: Object, Mappable {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  
  override static func primaryKey() -> String? {
    
    return "id"
  }
	
	required convenience init?(map: Map) {
		self.init()
		
	}
	func mapping(map: Map) {
		id <- map["artist_id"]
		name <- map["artist_name"]
	}
}

class Lyric: Object, Mappable {
  
  dynamic var id: Int = 0 //pk
  dynamic var name: String = ""
  dynamic var text: String = ""
  
  override static func primaryKey() -> String? {
    
    return "id"
  }
	
	required convenience init?(map: Map) {
		self.init()
	}
	func mapping(map: Map) {
		id <- map["lyrics_id"]
		name <- map["track_name"]
	}
}
//
//class Player: NSObject {
//  
//    static let sharedPlayer: Player = Player()
//    
//    override init() {
//        info = Info()
//    }
//    
//    var info: Info!
//}
//
struct Time {
	
	let allTimeString: String
	var timeInterval: Int = 0
	
	init(allTimeString: String) {
		
		self.allTimeString = allTimeString
		
		timeInterval = self.convertFrom(allTimeString)
	}
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
/*
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
      
      let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: "com.apple.iTunes"))
        
        guard let artist = iTunesApp.track_artist, let name = iTunesApp.track_name, let time = iTunesApp.track_time else {
            
            return
        }
      let track = PlayerTrack(artist: artist, name: name, time: time)
        MusiXMatchApi.searchTrackID(track) { (success, trackID) in
            //
        }
    }
    
    func getTrackPropertyAndValue(_ json: JSON) {
        
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
    
		
    
    let artist = Artist()
    artist.id = self.artist_id.intValue
    artist.name = self.artist_name
    
    let album = Album()
    album.id = self.album_id.intValue
    if let url = self.album_coverart_350x350 {
      album.url_str = url
      album.artwork = try? Data(contentsOf: URL(string: url)!)
    }
    album.artist = artist
		
		let track = Track()
		track.id = self.track_id.intValue
		track.name = self.track_name
		track.lyric_id = self.lyrics_id.intValue
		track.album_id = self.album_id.intValue
		track.spotify_id = self.track_spotify_id.intValue
		track.artist = artist
		
    let realm = try! Realm()
    
    try! realm.write {
      realm.add([track, artist, album])
    }
  }
}


*/
