//
//  PlaySourceable.swift
//  Lyricism
//
//  Created by Stan Liu on 21/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol PlayerSourceable {
	
	func setPlayerSource(_ type: App<String>)
	func getPlayerSource() -> App<String>
}

extension PlayerSourceable where Self: NSViewController {
	
	func setPlayerSource(_ type: App<String>) {
		
		switch type {
		case .itunes:
			UserDefaults.standard.set(0, forKey: Identifier.sourceKey)
		case .spotify:
			UserDefaults.standard.set(1, forKey: Identifier.sourceKey)
		}
	}
	
	func getPlayerSource() -> App<String> {
		
		switch UserDefaults.standard.integer(forKey: Identifier.sourceKey) {
		case 0:
			
			return .itunes("")
		case 1:
			return .spotify("")
		default:
			Debug.print("getPlayerSource SBApplicationID out of bounds, PlayerSourceable, Line: 33")
			return .itunes("")
		}
	}
}
