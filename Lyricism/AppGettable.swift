//
//  AppGettable.swift
//  Lyricism
//
//  Created by Stan Liu on 23/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import ScriptingBridge

protocol PlayerGettable { }

extension PlayerGettable {
	
	func iTunes(handler: (App<iTunesApplication>?) -> Void) {
		
		guard let itunesApp = SBApplication(bundleIdentifier: App.itunes("").identifiers().values().app) as? iTunesApplication else {
			
			return
		}
		handler(.itunes(itunesApp))
	}
	
	func spotify(handler: (App<SpotifyApplication>?) -> Void) {
		
		guard let spotifyApp = SBApplication(bundleIdentifier: App.spotify("").identifiers().values().app) as? SpotifyApplication else {
			
			return
		}
		handler(.spotify(spotifyApp))
	}
}
