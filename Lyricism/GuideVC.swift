//
//  GuideVC.swift
//  Lyricism
//
//  Created by Stan Liu on 24/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class GuideVC: NSViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		
		if let sourceVC = segue.destinationController as? SetPlayerSourceVC, segue.identifier == String(describing: SetPlayerSourceVC.self) {
			
			self.addChildViewController(sourceVC)
		}
	}
	
}
