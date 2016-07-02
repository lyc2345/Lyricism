//
//  PreferenceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    
    var currentSegueIdentifier: String!
    
    enum PreferenceType: String {
        
        case appearance
        case other
    }
    
    var currentViewController: NSViewController?
    var pastViewController: NSViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("preference view controller view did load")
        
        
    }
    
    func preferenceCategory(prefer: PreferenceType) {
        
        switch prefer {
        case .appearance:
            currentSegueIdentifier = PreferenceType.appearance.rawValue
        case .other:
            currentSegueIdentifier = PreferenceType.other.rawValue
        }
        
        performSegueWithIdentifier(currentSegueIdentifier, sender: self)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == currentSegueIdentifier {
            if pastViewController != nil {
                pastViewController?.view.removeFromSuperview()
            }
            
            guard let currentViewController = segue.destinationController as? NSViewController else {
            return
            }
            
            addChildViewController(currentViewController)
            currentViewController.view.frame = view.bounds
            view.addSubview(currentViewController.view)
            
            currentViewController.removeFromParentViewController()
            pastViewController = currentViewController
        }
    }
    
    
}
