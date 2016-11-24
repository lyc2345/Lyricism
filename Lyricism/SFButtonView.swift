//
//  SFButtonView.swift
//  Lyricism
//
//  Created by Stan Liu on 24/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import Then

class SFButtonView: NSView {
	
	var button: NSButton?
	
	var selector: Selector? {
		
		didSet {
			if let s = selector, let b = button {
				b.action = s
			}
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		

	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
		
		let _ = self.then() {
			
			$0.layer?.backgroundColor = NSColor.darkGray.cgColor
			
			$0.layer?.cornerRadius = self.frame.size.width / 2
			$0.layer?.borderColor = NSColor.red.cgColor
			$0.layer?.borderWidth = 3.0
			$0.layer?.masksToBounds = true
		}
		
		button = NSButton(image: NSImage.spotify, target: self, action: selector).then() {
			
			self.addSubview($0)
			
			$0.bezelStyle = .rounded
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
			$0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
			
			$0.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
			$0.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true
			$0.layer?.cornerRadius = self.frame.size.width / 2
			$0.layer?.masksToBounds = true
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		// Drawing code here.
	}
}
