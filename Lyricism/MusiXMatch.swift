//
//  MusiXMatch.swift
//  Lyricism
//
//  Created by Stan Liu on 30/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PlayerTrack {
  
  let artist: String
  let name: String
  let time: String
}

extension PlayerTrack: LyricsViewPresentable {
  
  var lvTime: String { return time }
  var lvArtistNTrack: (artist: String, trackName: String) { return (artist, name) }
  var lvTrack: PlayerTrack { return PlayerTrack(artist: artist, name: name, time: time) }
}
