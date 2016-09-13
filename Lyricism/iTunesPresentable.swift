//
//  iTunesPresentable.swift
//  Lyricism
//
//  Created by Stan Liu on 13/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import ScriptingBridge

protocol PlayerPresentable {
  
  associatedtype T
  
  var track_name: String? { get }
  var track_artist: String? { get }
  var track_time: T? { get }
  var track_time_position: Double? { get }
}

struct iTunes {

  let player: iTunesApplication?
}

struct Spotify {
  
  let player: SpotifyApplication?
}

extension iTunes: PlayerPresentable {
  
  var track_name: String? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.currentTrack?.name
  }
  
  var track_artist: String? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.currentTrack?.artist
  }
  
  var track_time: String? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.currentTrack?.time
  }
  
  var track_time_position: Double? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.playerPosition
  }
}
extension Spotify: PlayerPresentable {

  var track_name: String? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.currentTrack?.name
  }
  
  var track_artist: String? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.currentTrack?.artist
  }
  
  var track_time: Int? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.currentTrack?.duration
  }
  
  var track_time_position: Double? {
    
    guard let p = player else {
      
      return nil
    }
    
    return p.playerPosition
  }
}

protocol iTunesPresentable {
  
  var player: iTunesApplication? { get }
  var track_name: String { get }
  var track_artist: String { get }
  var track_time: String { get }
  var track_time_position: Double { get }
}

protocol SpotifyPresentable: PlayerPresentable {
  
  var player: SBApplication? { get }
  var track_name: String { get }
  var track_artist: String { get }
  var track_time: String { get }
  var track_time_position: Double { get }
}
