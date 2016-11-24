//
//  iTunesPresentable.swift
//  Lyricism
//
//  Created by Stan Liu on 13/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import ScriptingBridge

enum Identifier {
	
	case itunes
	case spotify
	
	func values() -> (app: String, playerstate: String, player: String) {
		
		switch self {
		case .itunes: return ("com.apple.iTunes", "com.apple.iTunes.playerInfo", "com.apple.iTunes.player")
		case .spotify: return ("com.spotify.client", "com.spotify.client.PlaybackStateChanged", "com.spotify.client")
		}
	}
}

enum App<T> {
	
	case itunes(T)
	case spotify(T)
}

extension App {
	
	func unwrap() -> T {
		switch self {
		case .itunes(let t): return t
		case .spotify(let t): return t
		}
	}
	
	func identifiers() -> Identifier {
		
		switch self {
		case .itunes: return Identifier.itunes
		case .spotify: return Identifier.spotify
		}
	}
}

