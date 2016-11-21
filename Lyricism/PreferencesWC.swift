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

class PreferencesWC: NSWindowController {
  
  @IBOutlet weak var toolBar: NSToolbar!
  
  var preferenceVC: PreferenceVC {
    
    return contentViewController as! PreferenceVC
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    
    preferenceVC.preferenceCategory(.appearance)
    toolBar.selectedItemIdentifier = PreferencesIdentifiers.appearance.rawValue
    
  }
  
  @IBAction func appearanceBtnPressed(_ sender: AnyObject) {
    
    preferenceVC.preferenceCategory(.appearance)
  }
  
  @IBAction func otherBtnPressed(_ sender: AnyObject) {
    
    preferenceVC.preferenceCategory(.other)
  }
  
  
}
