//
//  PlaySourceable.swift
//  Lyricism
//
//  Created by Stan Liu on 21/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

protocol PlayerSourceable {
	
	func setPlayerSource(_ type: App<String>)
	func getPlayerSource() -> App<String>
}

extension PlayerSourceable where Self: NSViewController {
	
	func setPlayerSource(_ type: App<String>) {
		
		Defaults[.playerSource] = type.source().value()
	}
	
	func getPlayerSource() -> App<String> {
		
		guard let source = Defaults[.playerSource] else {
			return .itunes("")
		}
		
		switch source {
		case Identifier.itunes.value():
			return .itunes("")
		case Identifier.spotify.value():
			return .spotify("")
		default:
			Debug.print("getPlayerSource SBApplicationID out of bounds, PlayerSourceable, Line: 33")
			return .itunes("")
		}
	}
}
