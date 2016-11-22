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
  
  var track_name: String? { get }
  var track_artist: String? { get }
  var track_time: String? { get }
  var track_time_position: Double? { get }
}


struct SBApp {

	let app: App<Any>
}

enum App<T> {
	
	//static let sourceKey = "player_source"
	
	case itunes(T)
	case spotify(T)
}
//
//extension App {
//	
//	/// If `self == nil`, returns `nil`.
//	/// Otherwise, returns `f(self!)`.
//	public func map<U>(f: (T) throws -> U)
//		rethrows -> U? {
//			switch self {
//			case .itunes(let y):
//				return .itunes(try f(y))
//			case .spotify(let y):
//				return .spotify(try f(y))
//			}
//	}
//	
//	/// Returns `nil` if `self` is `nil`,
//	/// `f(self!)` otherwise.
//	//@warn_unused_result
//	public func flatMap<U>(f: (T) throws -> U?)
//		rethrows -> U? {
//			switch self {
//			case .itunes(let y):
//				return try f(y)
//			case .spotify(let y):
//				return try f(y)
//			}
//	}
//}

extension App {
	
	func identifier() -> (app: String, playerstate: String, player: String) {
		
		switch self {
		case .itunes: return ("com.apple.iTunes", "com.apple.iTunes.playerInfo", "com.apple.iTunes.player")
		case .spotify: return ("com.spotify.client", "com.spotify.client.PlaybackStateChanged", "com.spotify.client")
		}
	}
	
	func spirit() -> T {
		switch self {
		case .itunes(let t): return t
		case .spotify(let t): return t
		}
	}
}

extension SBApp: PlayerPresentable {
	
	var track_name: String? {
		
		switch app {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				return nil
			}
			return p.currentTrack?.name
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				return nil
			}
			return p.currentTrack?.name
			
		}
	}
	
	var track_artist: String? {
		
		switch app {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				return nil
			}
			return p.currentTrack?.artist
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				return nil
			}
			return p.currentTrack?.artist
			
		}
	}
	
	var track_time: String? {
		
		switch app {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				return nil
			}
			return p.currentTrack?.time
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				return nil
			}
			return String(describing: p.currentTrack?.duration)
			
		}
	}
	
	var track_time_position: Double? {
		
		switch app {
		case .itunes(let t):
			guard let p = t as? iTunesApplication else {
				return nil
			}
			return p.playerPosition
			
		case .spotify(let t):
			guard let p = t as? SpotifyApplication else {
				return nil
			}
			return p.playerPosition
			
		}
	}

}

/*
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

struct iTunes: PlayerPresentable {
	
	let player: iTunesApplication?
}

struct Spotify: PlayerPresentable {
	
	let player: SpotifyApplication?
}

extension iTunes {
	
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
extension Spotify {
	
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
*/
