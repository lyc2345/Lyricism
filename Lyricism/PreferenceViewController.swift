//
//  PreferenceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController, ContainerSwitchable {
    
    enum PreferenceType: String {
        
        case appearance
        case other
    }
    
    @IBOutlet weak var containerView: NSView!
    
    var containerViewController: NSViewController!
    
    var appearanceViewController: AppearanceViewController?
    
    var tTarget: NSViewController { return self }
    var tContainerView: NSView { return containerView }
    var currentViewController: NSViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
      
      
    }
    
    func preferenceCategory(prefer: PreferenceType) {
    
        var newViewController: NSViewController!
        let preferenceStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
        
        switch prefer {
        case .appearance:
            newViewController = preferenceStoryboard.instantiateControllerWithIdentifier(String(AppearanceViewController)) as? AppearanceViewController
        case .other:
            newViewController = preferenceStoryboard.instantiateControllerWithIdentifier(String(AppearanceViewController)) as? AppearanceViewController
        }
        
        cycleFromViewController(currentViewController, toViewController: newViewController)
    }
    
  @available(OSX 10.10, *)
  override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationController is PreferenceViewController {
            
            containerViewController = segue.destinationController as? PreferenceViewController
        }
    }
}
