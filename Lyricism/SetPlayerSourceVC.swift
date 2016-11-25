//
//  SetPlayerSourceVC.swift
//  Lyricism
//
//  Created by Stan Liu on 24/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class SetPlayerSourceVC: NSViewController {
	
	@IBOutlet weak var iTunesBtn: NSButton!
	@IBOutlet weak var spotifyBtn: NSButton!
	
	lazy var buttons: [NSButton] = {
		
		return [self.iTunesBtn, self.spotifyBtn]
	}()
	
	private var source: Identifier?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		roundButton()
	}

	@IBAction func chooseiTunes(_ sender: Any) {
		clear()
		source = .itunes
		
		iTunesBtn.selected(true)
	}
	
	@IBAction func chooseSpotify(_ sender: Any) {
		clear()
		source = .spotify
		
		spotifyBtn.selected(true)
	}
	
	@IBAction func confirm(_ sender: Any) {
		
		guard let s = source, let appDelegate = NSApplication.shared().delegate as? AppDelegate else {
			// TODO: Alert to notify user to choose source
			return
		}
		
		switch s {
			
		case .itunes:
			
			appDelegate.iTunesSetup()
			
		case .spotify:
			
			appDelegate.spotifySetup()
		}
		
		self.parent?.view.window?.close()
	}

	
	func roundButton() {
		
		buttons.forEach() {
			
			$0.layer?.cornerRadius = $0.frame.size.width / 2
			$0.layer?.masksToBounds = true
		}
	}
	
	func clear() {
		
		buttons.forEach() {
			
			$0.selected(false)
		}
	}
}
