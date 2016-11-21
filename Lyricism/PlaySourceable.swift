//
//  PlaySourceable.swift
//  Lyricism
//
//  Created by Stan Liu on 21/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol PlayerSourceable {
	
	func setPlayerSource(_ type: SBApplicationID)
	func getPlayerSource() -> SBApplicationID
}

extension PlayerSourceable where Self: NSViewController {
	
	func setPlayerSource(_ type: SBApplicationID) {
		
		switch type {
		case .itunes: UserDefaults.standard.set(0, forKey: SBApplicationID.sourceKey)
		case .spotify:
			UserDefaults.standard.set(1, forKey: SBApplicationID.sourceKey)
		}
	}
	
	func getPlayerSource() -> SBApplicationID {
		
		switch UserDefaults.standard.integer(forKey: SBApplicationID.sourceKey) {
		case 0: return SBApplicationID.itunes
		case 1: return SBApplicationID.spotify
		default:
			s_print("getPlayerSource SBApplicationID out of bounds, PlayerSourceable, Line: 33")
			return SBApplicationID.itunes
		}
	}
}
