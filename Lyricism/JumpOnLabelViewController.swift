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
  
  var backgroundView: ColorBackgroundView?
  override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    if let frameView = self.window?.contentView?.superview {
      if backgroundView == nil {
        
        backgroundView = ColorBackgroundView(frame: frameView.bounds)
        backgroundView!.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
        frameView.addSubview(backgroundView!, positioned: NSWindowOrderingMode.Below, relativeTo: frameView)
      }
    }
  }
}
// Change Triagle Background Color
class ColorBackgroundView: NSView {
  
  override func drawRect(dirtyRect: NSRect) {
    NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 6.0).set()
    NSRectFill(bounds)
  }
}


class JumpOnLabelViewController: NSViewController {
  
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
    titleLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 0).active = true
    titleLabel.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: 0).active = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    traigleView = PopoverContentViewJumpOnLabel(frame: view.frame)
    view.addSubview(traigleView!)
    
    view.layoutSubtreeIfNeeded()
  }
}
