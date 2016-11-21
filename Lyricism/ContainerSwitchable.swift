//
//  ContainerSwitchable.swift
//  Lyricism
//
//  Created by Stan Liu on 02/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol ContainerSwitchable: class {
    
    var tTarget: NSViewController { get }
    var tContainerView: NSView { get }
    var currentViewController: NSViewController? { get set }
}


extension ContainerSwitchable where Self: NSViewController {
    
    func cycleFromViewController(_ oldViewController: NSViewController?, toViewController newViewController: NSViewController)  {
        
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        currentViewController = newViewController
        
        
        tTarget.addChildViewController(newViewController)
        addSubview(newViewController.view, toView:tContainerView)
        newViewController.view.alphaValue = 0
        newViewController.view.layoutSubtreeIfNeeded()
        /*
        NSView.animateWithDuration(0.5, animations: {
            
            newViewController.view.alphaValue = 1
            oldViewController?.view.alphaValue = 0
            
            }, completion: { finished in
                
                oldViewController?.view.removeFromSuperview()
                oldViewController?.removeFromParentViewController()
                newViewController.didMoveToParentViewController(self.tTarget)
        })*/
        
        newViewController.view.alphaValue = 1
        oldViewController?.view.alphaValue = 0
        
        oldViewController?.view.removeFromSuperview()
        oldViewController?.removeFromParentViewController()
    }
    
    // 把新的ViewController.view 貼到containerView上, 新的view需要autolayout
    func addSubview(_ subView: NSView, toView parentView: NSView) {
        
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
}
