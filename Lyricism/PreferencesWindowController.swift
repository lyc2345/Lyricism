//
//  PreferencesWindownController.swift
//  LyriKing
//
//  Created by Stan Liu on 22/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

enum PreferencesIdentifiers: String {
  
  case appearance = "appearance"
  case other = ""
}

class PreferencesWindowController: NSWindowController {
  
  @IBOutlet weak var toolBar: NSToolbar!
  
  var preferenceViewController: PreferenceViewController {
    
    return contentViewController as! PreferenceViewController
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    
    preferenceViewController.preferenceCategory(.appearance)
    toolBar.selectedItemIdentifier = PreferencesIdentifiers.appearance.rawValue
    
  }
  
  @IBAction func appearanceBtnPressed(sender: AnyObject) {
    
    preferenceViewController.preferenceCategory(.appearance)
  }
  
  @IBAction func otherBtnPressed(sender: AnyObject) {
    
    preferenceViewController.preferenceCategory(.other)
  }
  
  
}
