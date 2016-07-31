//
//  MusiXMatch.swift
//  Lyricism
//
//  Created by Stan Liu on 30/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation

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