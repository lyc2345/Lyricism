//: Playground - noun: a place where people can play

import Cocoa

enum Identifier {
	static let sourceKey = "player_source"
	
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

App.itunes("").identifiers().values().app

let itunes = App.itunes(Identifier.itunes)






