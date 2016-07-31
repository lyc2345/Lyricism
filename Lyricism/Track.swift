//
//  Track.swift
//  LyriKing
//
//  Created by Stan Liu on 01/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyJSON

class Track: NSObject {
    
    static let sharedTrack: Track = Track()
    
    override init() {
        info = Info()
    }
    
    var info: Info!
}

class Info: NSObject {
    
    var has_lyrics: NSNumber!
    
    var track_share_url: String!
    var commontrack_vanity_id: String!
    var restricted: NSNumber!
    var track_spotify_id: String!
    var track_id: NSNumber!
    var artist_mbid: String!
    var artist_name: String!
    var album_coverart_800x800: String?
    var artist_id: NSNumber!
    var updated_time: String!
    var album_id: NSNumber!
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
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        
        guard let artist = iTunes.currentTrack?.artist, name = iTunes.currentTrack?.name, time = iTunes.currentTrack?.time else {
            
            return
        }
        let track = MusiXTrack(artist: artist, name: name, lyrics: nil, time: time, artwork: nil)
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
}