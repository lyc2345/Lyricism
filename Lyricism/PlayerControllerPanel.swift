//
//  PlayerControllerPanel.swift
//  LyriKing
//
//  Created by Stan Liu on 29/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class PlayerControllerPanel: NSView {
    
    var view: NSView!
    var array: NSArray!
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)

    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 0.4).set()
        NSRectFill(bounds)

    }
    
}
