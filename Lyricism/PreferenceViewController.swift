//
//  PreferenceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    
    enum PreferenceType: String {
        
        case appearance
        case other
    }
    
    @IBOutlet weak var containerView: NSView!
    
    var containerViewController: NSViewController!
    
    var appearanceViewController: AppearanceViewController?
    
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
        
        cycleFrom(currentViewController, to: newViewController)
    }
    
    func addSubview(subview: NSView, to parentview: NSView) {
        
        parentview.addSubview(subview)
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subview
        parentview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func cycleFrom(oldViewController: NSViewController?, to newViewController: NSViewController) {
        
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(newViewController)
        
        addSubview(newViewController.view, to: containerView)
        
        newViewController.view.alphaValue = 0
        newViewController.view.layoutSubtreeIfNeeded()
        
        /*
        UIView.animateWithDuration(0.5, animations: {
            
            newViewController.view.alpha = 1
            oldViewController?.view.alpha = 0
            
            }, completion: { finished in
                
                oldViewController?.view.removeFromSuperview()
                oldViewController?.removeFromParentViewController()
                newViewController.didMoveToParentViewController(self)
                self.wcToolViewController = newViewController
        })*/

        newViewController.view.alphaValue = 1
        oldViewController?.view.alphaValue = 0
        
        oldViewController?.view.removeFromSuperview()
        oldViewController?.removeFromParentViewController()
        
        currentViewController = newViewController
    }
    
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationController is PreferenceViewController {
            
            containerViewController = segue.destinationController as? PreferenceViewController
        }
    }
}
