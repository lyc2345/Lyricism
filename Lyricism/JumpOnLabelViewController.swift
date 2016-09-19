//
//  JumpOnLabelViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 01/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

// Change Triagle Background Color
class PopoverContentViewJumpOnLabel: NSView {
  
  var backgroundViewLayer: ColorBackgroundView?
  
  override func viewDidMoveToWindow() {
    
    if let frameView = self.window?.contentView?.superview where backgroundViewLayer == nil {
      
        backgroundViewLayer = ColorBackgroundView(frame: frameView.bounds)
        backgroundViewLayer!.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
        frameView.addSubview(backgroundViewLayer!, positioned: NSWindowOrderingMode.Below, relativeTo: frameView)
    }
    super.viewDidMoveToWindow()
  }
}
// Change Triagle Background Color
class ColorBackgroundView: NSView {
  
  // NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
  var color: NSColor = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
  
  override func drawRect(dirtyRect: NSRect) {
    
    color.set()
    NSRectFill(bounds)
  }
}

// dark blue: NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
// Spotify green: NSColor(colorLiteralRed: 90.0/255.0, green: 213.0/255.0, blue: 79.0/255.0, alpha: 6.0)
// iTunes white: NSColor(colorLiteralRed: 218.0/255.0, green: 223.0/255.0, blue: 227.0/255.0, alpha: 6.0)
// iTunes font: NSColor(colorLiteralRed: 230.0/255.0, green: 62.0/255.0, blue: 92.0/255.0, alpha: 6.0)

class JumpOnLabelViewController: NSViewController {
  
  var source: SBApplicationID = .itunes {
    
    didSet {
      
      switch source {
      case .itunes:
        (traigleView as! PopoverContentViewJumpOnLabel).backgroundViewLayer!.color = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
        titleLabel.textColor = NSColor.whiteColor()
      case .spotify:
        (traigleView as! PopoverContentViewJumpOnLabel).backgroundViewLayer!.color = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
        titleLabel.textColor = NSColor.whiteColor()
      }
    }
  }
  
  @IBOutlet weak var titleLabel: NSTextField! {
    
    didSet {
      
      titleLabel.font = NSFont(name: "Lato Regular", size: 12)
      titleLabel.textColor = NSColor.whiteColor()
      titleLabel.alignment = .Center
    }
  }
  
  var trackTitle: String = "" {
    didSet {
      
      self.titleLabel.stringValue = trackTitle
    }
  }
  
  var traigleView: NSView?
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 0).active = true
    titleLabel.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: 0).active = true
    //titleLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 0).active = true
    //titleLabel.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: 0).active = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    traigleView = PopoverContentViewJumpOnLabel(frame: view.frame)
    view.addSubview(traigleView!)
    
    view.layoutSubtreeIfNeeded()
  }
}
