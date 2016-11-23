//
//  TrackInfoGettable.swift
//  Lyricism
//
//  Created by Stan Liu on 23/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation

protocol TrackInfoGettable {
	
	var track_name: String? { get }
	var track_artist: String? { get }
	var track_time: String? { get }
	var track_time_position: Double? { get }
}

extension App: TrackInfoGettable {
	
	var track_name: String? {
		
		switch self {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.currentTrack?.name
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.currentTrack?.name
			
		}
	}
	
	var track_artist: String? {
		
		switch self {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.currentTrack?.artist
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.currentTrack?.artist
			
		}
	}
	
	var track_time: String? {
		
		switch self {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.currentTrack?.time
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return String(describing: p.currentTrack?.duration)
			
		}
	}
	
	var track_time_position: Double? {
		
		switch self {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.playerPosition
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				
				fatalError("Generic Type 'T' is not SBApplication")
			}
			return p.playerPosition
			
		}
	}
}
