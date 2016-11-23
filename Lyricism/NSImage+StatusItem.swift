//
//  NSImage+StatusItem.swift
//  
//
//  Created by Stan Liu on 23/11/2016.
//
//

import Cocoa

extension NSImage {
	
	class var noteLight: NSImage {
		
		return self.init(named: Assets.StatusItem.light.rawValue)!
	}
	
	class var noteDark: NSImage {
		
		return self.init(named: Assets.StatusItem.dark.rawValue)!
	}
	
	class var iTunes: NSImage {
		
		return self.init(named: Assets.Player.itunes.rawValue)!
	}
	
	class var spotify: NSImage {
		
		return self.init(named: Assets.Player.spotify.rawValue)!
	}
}

