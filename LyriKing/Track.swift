//
//  Track.swift
//  macOS
//
//  Created by Stan Liu on 17/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyJSON

class Track: NSObject {
    
    override init() {
        super.init()
        
    }
    
    static let sharedTrack: Track = Track()
    
    var has_lyrics: NSNumber!
    
    var track_share_url: String!
    var commontrack_vanity_id: String!
    var restricted: NSNumber!
    var track_spotify_id: String!
    var track_id: NSNumber!
    var artist_mbid: String!
    var artist_name: String!
    var album_coverart_800x800: String!
    var artist_id: NSNumber!
    var updated_time: String!
    var album_id: NSNumber!
    var album_coverart_100x100: String!
    var first_release_date: String!
    var album_coverart_350x350: String!
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
    
    
    func getCurrentTrackID() {
        //TODO: Clean up this code after testing
        /*
        if let playingTrack = MacUtilities.getCurrentMusicInfo() {
            
            MusiXMatchApi.getTrackInfo(playingTrack.artist, track: playingTrack.track, completion: { (success) in
            
                if success {
                    
                    
                }
            })
        }*/
    }
    
    func getTrackPropertyAndValue(json: JSON) -> Track? {
        
        let track = Track.sharedTrack
        let properties = track.propertyNames()
        
        for key in properties {
            
            if let stringValue = json["message"]["body"]["track_list"][0]["track"][key].string {
                
                //print("property: \(key), value: \(stringValue)")
                track.setValue(stringValue, forKey: key)
            } else if let numberValue = json["message"]["body"]["track_list"][0]["track"][key].int {
                
                //print("property: \(key), value: \(value)")
                track.setValue(numberValue, forKey: key)
            } else {
                
                //primary_genre
                if let _ = json["message"]["body"]["track_list"][0]["track"]["primary_genres"].dictionary {
                    //print("property: \(key), value: \(primary_genres)")
                    
                }
                if let genreStringValue = json["message"]["body"]["track_list"][0]["track"]["primary_genres"]["music_genre_list"][0]["music_genre"][key].string {
                    
                    track.setValue(genreStringValue, forKey: key)
                    
                }
                if let genreNumberValue = json["message"]["body"]["track_list"][0]["track"]["primary_genres"]["music_genre_list"][0]["music_genre"][key].number {
                    
                    track.setValue(genreNumberValue, forKey: key)
                }
                
            }
        }
        return track
    }
}
