//
//  SFPopover.swift
//  LyriKing
//
//  Created by Stan on 7/21/16.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol PopoverSizable {
    
    func getSize(type: SFPopoverContainer.PopoverType) -> CGSize
}

extension PopoverSizable {
    
    func getSize(type: SFPopoverContainer.PopoverType) -> CGSize {
        
        return type.rawValue().sizeValue
    }
}

protocol Popoverable: PopoverSizable {
    
    func show(viewController vc: NSViewController, at sender: NSView, handler:(viewController: NSViewController) -> Void)
}

class SFPopover: NSPopover, Popoverable {
    
    func viewController(type: SFPopoverContainer.PopoverType) -> NSViewController {
        
        let identifier = type.rawValue().identifierValue
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateControllerWithIdentifier(identifier) as! NSViewController
    }
    
  func show(viewController vc: NSViewController, at sender: NSView, handler:(viewController: NSViewController) -> Void) {
        
        contentViewController = vc
        contentSize = (vc is LyricsViewController) ? getSize(.lyrics) : getSize(.prompt)
        animates = true
        behavior = .Transient
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: .MinY)
        });
        
        handler(viewController: vc)
    }
    
    func show(type: SFPopoverContainer.PopoverType, at view: NSView, handler:(viewController: NSViewController) -> Void) {
        
        let vc = viewController(type)
        contentViewController = vc
        contentSize = getSize(type)
        animates = true
        behavior = .Transient
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.showRelativeToRect(view.bounds, ofView: view, preferredEdge: .MinY)
        })
        
        handler(viewController: vc)
    }
    
    func close(handler: ((Void) -> Void)?) {
        
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
    let lyricsViewController: LyricsViewController
    let jumpOnLabelViewController: JumpOnLabelViewController

    enum PopoverType {
        
        case lyrics, prompt
        
        func rawValue() -> (sizeValue: CGSize, identifierValue: String) {
            
            switch self {
            case .lyrics:
                return (CGSizeMake(350, 350), String(LyricsViewController))
                
            case .prompt:
                return (CGSizeMake(30, 25), String(JumpOnLabelViewController))
            }
        }
    }
}

extension SFPopoverContainer: Popoverable {
    
    func viewController(type: SFPopoverContainer.PopoverType) -> NSViewController {
        
        let identifier = type.rawValue().identifierValue
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateControllerWithIdentifier(identifier) as! NSViewController
    }
    
    func show(viewController vc: NSViewController, at sender: NSView, handler:(viewController: NSViewController) -> Void) {
        
        popover.contentViewController = vc
        popover.contentSize = (vc is LyricsViewController) ? getSize(.lyrics) : getSize(.prompt)
        popover.animates = true
        popover.behavior = .Transient
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.popover.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: .MaxY)
        });
        
        handler(viewController: vc)
    }
    
    func show(type: SFPopoverContainer.PopoverType, at view: NSView, handler:(viewController: NSViewController) -> Void) {
        
        let vc = viewController(type)
        popover.contentViewController = vc
        popover.contentSize = getSize(type)
        popover.animates = true
        popover.behavior = .Transient
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        self.popover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: .MaxY)
            })
        
        handler(viewController: vc)
    }
    
    func close(handler: ((Void) -> Void)?) {
        
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