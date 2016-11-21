//
//  SFPopover.swift
//  LyriKing
//
//  Created by Stan on 7/21/16.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol PopoverSizable {
    
    func getSize(_ type: SFPopoverContainer.PopoverType) -> CGSize
}

extension PopoverSizable {
    
    func getSize(_ type: SFPopoverContainer.PopoverType) -> CGSize {
        
        return type.rawValue().sizeValue
    }
}

protocol Popoverable: PopoverSizable {
    
    func show(viewController vc: NSViewController, at sender: NSView, handler:(_ viewController: NSViewController) -> Void)
}

class SFPopover: NSPopover, Popoverable {
    
    func viewController(_ type: SFPopoverContainer.PopoverType) -> NSViewController {
        
        let identifier = type.rawValue().identifierValue
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateController(withIdentifier: identifier) as! NSViewController
    }
    
  func show(viewController vc: NSViewController, at sender: NSView, handler:(_ viewController: NSViewController) -> Void) {
        
        contentViewController = vc
        contentSize = (vc is LyricsVC) ? getSize(.lyrics) : getSize(.prompt)
        animates = true
        behavior = .transient
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        });
        
        handler(vc)
    }
    
    func show(_ type: SFPopoverContainer.PopoverType, at view: NSView, handler:(_ viewController: NSViewController) -> Void) {
        
        let vc = viewController(type)
        contentViewController = vc
        contentSize = getSize(type)
        animates = true
        behavior = .transient
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        })
        
        handler(vc)
    }
    
    func close(_ handler: ((Void) -> Void)?) {
        
        if let h = handler {
            h()
        }
        //s_print("close popover")
        performClose(self)
    }
    
    func toggle(from vc1: NSViewController, to vc2: NSViewController, at view: NSView, handler: (Void) -> Void) {
        /*
         if self.shown {
         close(){  }
         } else {
         show(vc2, at: view, handler: handler)
         }*/
    }
}

struct SFPopoverContainer {
    
    let popover: NSPopover
    let lyricsViewController: LyricsVC
    let popoverVC: PopoverVC

    enum PopoverType {
        
        case lyrics, prompt
        
        func rawValue() -> (sizeValue: CGSize, identifierValue: String) {
            
            switch self {
            case .lyrics:
                return (CGSize(width: 350, height: 350), String(describing: LyricsVC.self))
                
            case .prompt:
                return (CGSize(width: 30, height: 25), String(describing: PopoverVC.self.self))
            }
        }
    }
}

extension SFPopoverContainer: Popoverable {
    
    func viewController(_ type: SFPopoverContainer.PopoverType) -> NSViewController {
        
        let identifier = type.rawValue().identifierValue
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateController(withIdentifier: identifier) as! NSViewController
    }
    
    func show(viewController vc: NSViewController, at sender: NSView, handler:(_ viewController: NSViewController) -> Void) {
        
        popover.contentViewController = vc
        popover.contentSize = (vc is LyricsVC) ? getSize(.lyrics) : getSize(.prompt)
        popover.animates = true
        popover.behavior = .transient
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
        });
        
        handler(vc)
    }
    
    func show(_ type: SFPopoverContainer.PopoverType, at view: NSView, handler:(_ viewController: NSViewController) -> Void) {
        
        let vc = viewController(type)
        popover.contentViewController = vc
        popover.contentSize = getSize(type)
        popover.animates = true
        popover.behavior = .transient
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
        self.popover.show(relativeTo: view.bounds, of: view, preferredEdge: .maxY)
            })
        
        handler(vc)
    }
    
    func close(_ handler: ((Void) -> Void)?) {
        
        if let h = handler {
            h()
        }
        //s_print("close popover")
        popover.performClose(popover)
    }
    
    func toggle(from vc1: NSViewController, to vc2: NSViewController, at view: NSView, handler: (Void) -> Void) {
        /*
         if self.shown {
         close(){  }
         } else {
         show(vc2, at: view, handler: handler)
         }*/
    }
}


/*
extension SFPopover: NSPopoverDelegate {
    
    func popoverDidShow(notification: NSNotification) {
        //s_print("Popover did show")
    }
    
    func popoverWillShow(notification: NSNotification) {
    }
    
    // popover windows set apart with status button
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
    
    func popoverDidClose(notification: NSNotification) {
    }
}*/
