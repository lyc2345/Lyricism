//
//  AppDelegate.swift
//  macOS
//
//  Created by Stan Liu on 16/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover: NSPopover = NSPopover()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // button image on status bar
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(printQuote)
        }
        
        

        let lyricsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("lyrics_view_controller") as! LyricsViewController
        
        popover.contentViewController = lyricsViewController
        popover.contentSize = NSMakeSize(200, 220)
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func printQuote(sender: AnyObject) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        togglePopover(popover)
    }

    func showPopover(sender: AnyObject?) {
        
        
        if let button = statusItem.button {
            (sender as! NSPopover).showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
            
            
        }
    }
    
    func closePopover(sender: AnyObject?) {
        (sender as! NSPopover).performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        
        if (sender as! NSPopover).shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

