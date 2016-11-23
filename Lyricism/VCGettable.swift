//
//  VCGettable.swift
//  Lyricism
//
//  Created by Stan Liu on 23/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

extension NSObject {
	
	class var classIdentifier: String {
		return String(describing: self)
	}
	
	var classIdentifier: String {
		return type(of: self).classIdentifier
	}
}

protocol VCGettable { }

extension VCGettable where Self: NSViewController {
	
	static func instantiate() -> Self {
		let storyboard = NSStoryboard(name: self.classIdentifier, bundle: nil)
		return storyboard.instantiateController(withIdentifier: self.classIdentifier) as! Self
	}
	
	static func instantiate(withStoryboard storyboard: String) -> Self {
		let storyboard = NSStoryboard(name: storyboard, bundle: nil)
		return storyboard.instantiateController(withIdentifier: self.classIdentifier) as! Self
	}
}

extension NSViewController: VCGettable { }

