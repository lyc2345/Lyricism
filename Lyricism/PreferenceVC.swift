//
//  PreferenceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class PreferenceVC: NSViewController, ContainerSwitchable {
    
    @IBOutlet weak var containerView: NSView!
    
    var containerViewController: NSViewController!
    
    var appearanceViewController: AppearanceViewController?
    
    var tTarget: NSViewController { return self }
    var tContainerView: NSView { return containerView }
    var currentViewController: NSViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
      
      
    }
    
    func preferenceCategory(_ prefer: PreferencesIdentifiers) {
    
        var newViewController: NSViewController!
        let preferenceStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
        
        switch prefer {
        case .appearance:
            newViewController = preferenceStoryboard.instantiateController(withIdentifier: String(describing: AppearanceViewController.self)) as? AppearanceViewController
        case .other:
            newViewController = preferenceStoryboard.instantiateController(withIdentifier: String(describing: AppearanceViewController.self)) as? AppearanceViewController
        }
        
        cycleFromViewController(currentViewController, toViewController: newViewController)
    }
    
  @available(OSX 10.10, *)
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if segue.destinationController is PreferenceVC {
            
            containerViewController = segue.destinationController as? PreferenceVC
        }
    }
}
