//
//  TimeFormattable.swift
//  Lyricism
//
//  Created by Stan Liu on 21/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol TimeFormattable { }

extension TimeFormattable {
	
	func convertFrom(_ timeString: String) -> Int {
		
		let s = String(timeString.characters.dropFirst(2)).copy() as! NSString
		let m = String(timeString.characters.dropLast(3)).replacingOccurrences(of: "-", with: "").copy() as! NSString
		
		return Int(m.intValue * 60 + s.intValue) - Int(0)
	}
	
}

extension Time: TimeFormattable { }

extension TimeFormattable where Self: NSViewController {
//	
//	func currentTimeFromInt(_ time: Int, playingHandler: (Void) -> (), stopHandler: (Void) -> ()) -> Int {
//		
//		let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
//		
//		guard let i = iTunesApp.player, let iplayerPos = iTunesApp.player?.playerPosition, i.running && i.playerState == .playing else {
//			
//			let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
//			
//			guard let s = spotifyApp.player, let splayerPos = spotifyApp.player?.playerPosition, s.running else {
//				
//				return time - Int(0)
//			}
//			
//			stopHandler()
//			playingHandler()
//			//stopTimer()
//			//initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
//			
//			return time - Int(splayerPos)
//		}
//		
//		if i.playerState == iTunesEPlS.playing {
//			stopHandler()
//			playingHandler()
//			//stopTimer()
//			//initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
//			
//		} else if i.playerState == iTunesEPlS.paused {
//			//stopTimer()
//			stopHandler()
//		} else if i.playerState == iTunesEPlS.stopped {
//			//stopTimer()
//			stopHandler()
//		} else{
//			print("Lyrics View Controller is not in the case")
//		}
//		return time - Int(iplayerPos)
//	}
}

extension LyricVC: TimeFormattable { }
