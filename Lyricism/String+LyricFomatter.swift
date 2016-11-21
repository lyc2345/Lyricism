//
//  String+LyricFomatter.swift
//  Lyricism
//
//  Created by Stan Liu on 21/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation

extension String {
	
	func applyLyricsFormat() -> String {
		
		return self == "" ? NSLocalizedString("Couldn't Find Any Relative Lyrics", comment: "Couldn't Find Any Relative Lyrics") : self.replacingOccurrences(of: ".", with: ". \n").replacingOccurrences(of: "  ", with: "\n")
	}
}
