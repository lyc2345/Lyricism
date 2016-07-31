//
//  SFPopover.swift
//  LyriKing
//
//  Created by Stan on 7/21/16.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class SFPopover: NSPopover {

    enum PopoverType {
        
        case lyrics, prompt
        
        func rawValue() -> (sizeValue: CGSize, identifierValue: String) {
            
            switch self {
            case .lyrics:
                return (CGSizeMake(350, 350), String(LyricsViewController))
                
            case .prompt:
                return (CGSizeMake(320, 25), String(JumpOnLabelViewController))
            }
        }
    }
    
    override init() {
        
        super.init()
        //contentSize = PopoverType.lyrics.rawValue().sizeValue
        //contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    private func getSize(type: PopoverType) -> CGSize {
        
        return type.rawValue().sizeValue
    }
    
    private func viewController(type: PopoverType) -> NSViewController {
        
        let identifier = type.rawValue().identifierValue
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        return storyboard.instantiateControllerWithIdentifier(identifier) as! NSViewController
    }

    func show(viewController vc: NSViewController, at sender: NSView, handler:(Void) -> Void) {

        contentViewController = vc
        contentSize = (vc is LyricsViewController) ? getSize(.lyrics) : getSize(.prompt)
        showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: .MaxY)
        
        handler()
    }
    
    func show(type: PopoverType, at view: NSView, handler:(viewController: NSViewController) -> Void) {
        
        let vc = viewController(type)
        contentViewController = vc
        contentSize = getSize(type)
        showRelativeToRect(view.bounds, ofView: view, preferredEdge: .MaxY)
        
        handler(viewController: vc)
    }
    
    func close(handler: ((Void) -> Void)?) {
        
        if let h = handler {
            h()
        }
        //print("close popover")
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

extension SFPopover: NSPopoverDelegate {
    
    
    func popoverDidShow(notification: NSNotification) {
        //print("Popover did show")
    }
    
    func popoverWillShow(notification: NSNotification) {
        
    }
    
    // popover windows set apart with status button
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        
        return true
    }
    
    func popoverDidClose(notification: NSNotification) {
        
        
    }

    
}