//
//  PopoverContentView.swift
//  Lyricism
//
//  Created by Stan Liu on 31/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

// This is For LyricViewController use only, not JumpOnLabel

// Change Triagle Background Color
class PopoverContentView: NSView {
    
    var backgroundView: PopoverBackgroundView?
    override func viewDidMoveToWindow() {
        
        super.viewDidMoveToWindow()
        
        if let frameView = self.window?.contentView?.superview {
            if backgroundView == nil {
                
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
                frameView.addSubview(backgroundView!, positioned: NSWindowOrderingMode.Below, relativeTo: frameView)
            }
        }
    }
}
// Change Triagle Background Color
class PopoverBackgroundView: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 0.4).set()
        NSRectFill(bounds)
    }
}
