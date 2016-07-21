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
        
        contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    func getSize(viewController: NSViewController) -> CGSize {
        
        if viewController is LyricsViewController {
            return CGSizeMake(350, 350)
        } else {
            return CGSizeMake(200, 25)
        }
    }
    
    func show(viewController: NSViewController, at view: NSView, handler: (Void) -> Void) {

        print("show popover")
        contentViewController = viewController
        contentSize = getSize(viewController)
        showRelativeToRect(view.bounds, ofView: view, preferredEdge: .MaxY)
        handler()
    }
    
    func close(handler: ((Void) -> Void)?) {
        
        if let h = handler {
            h()
        }
        print("close popover")
        performClose(self)
    }
    
    func toggle(from vc1: NSViewController, to vc2: NSViewController, at view: NSView, handler: (Void) -> Void) {
        
        if self.shown {
            close(){  }
        } else {
            show(vc2, at: view, handler: handler)
        }
    }

}

extension SFPopover: NSPopoverDelegate {
    
    
    func popoverDidShow(notification: NSNotification) {
        print("Popover did show")
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