//
//  BlurBackground.swift
//  macOS
//
//  Created by Stan Liu on 21/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class BlurBackground: NSView {
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        setBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        setBackgroundColor()
    }
    
    override func awakeFromNib() {
        
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        
        wantsLayer = true
        layer?.backgroundColor = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 0.4).CGColor
        
    }
    

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
}
