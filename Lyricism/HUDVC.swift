//
//  JumpOnLabelViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 01/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

// Change Triagle Background Color
class TriangleBackgroundView: NSView {
  
  var backgroundViewLayer: ColorBackgroundView?
  
  override func viewDidMoveToWindow() {
    
    if let frameView = self.window?.contentView?.superview, backgroundViewLayer == nil {
      
        backgroundViewLayer = ColorBackgroundView(frame: frameView.bounds)
        backgroundViewLayer!.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewHeightSizable]);
        frameView.addSubview(backgroundViewLayer!, positioned: NSWindowOrderingMode.below, relativeTo: frameView)
    }
    super.viewDidMoveToWindow()
  }
}
// Change Triagle Background Color
class ColorBackgroundView: NSView {
  
  // NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
  var color: NSColor = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
  
  override func draw(_ dirtyRect: NSRect) {
    
    color.set()
    NSRectFill(bounds)
  }
}

// dark blue: NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
// Spotify green: NSColor(colorLiteralRed: 90.0/255.0, green: 213.0/255.0, blue: 79.0/255.0, alpha: 6.0)
// iTunes white: NSColor(colorLiteralRed: 218.0/255.0, green: 223.0/255.0, blue: 227.0/255.0, alpha: 6.0)
// iTunes font: NSColor(colorLiteralRed: 230.0/255.0, green: 62.0/255.0, blue: 92.0/255.0, alpha: 6.0)

class HUDVC: NSViewController {
	
  var source: App<String> = .itunes("") {
    
    didSet {
      
      switch source {
      case .itunes:
        traigleView?.backgroundViewLayer!.color = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
        titleLabel.textColor = NSColor.white
      case .spotify:
        traigleView?.backgroundViewLayer!.color = NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0)
        titleLabel.textColor = NSColor.white
      }
    }
  }
  
  @IBOutlet weak var titleLabel: NSTextField! {
    
    didSet {
      
      titleLabel.font = NSFont.fontForPopover()
      titleLabel.textColor = NSColor.white
      titleLabel.alignment = .center
    }
  }
  
  var trackTitle: String = "" {
    didSet {
      
      self.titleLabel.stringValue = trackTitle
    }
  }
  
  var traigleView: TriangleBackgroundView?
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    //titleLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 0).active = true
    //titleLabel.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: 0).active = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    traigleView = TriangleBackgroundView(frame: view.frame)
    view.addSubview(traigleView!)
    
    view.layoutSubtreeIfNeeded()
  }
}
