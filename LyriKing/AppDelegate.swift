//
//  AppDelegate.swift
//  macOS
//
//  Created by Stan Liu on 16/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import SwiftyJSON
import ScriptingBridge
import MediaLibrary

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover: NSPopover = NSPopover()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // button image on status bar
        if let button = statusItem.button {
            button.image = NSImage(named: "light_lyrics")
            button.action = #selector(togglePopover)
        }
        
        let lyricsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("lyrics_view_controller") as! LyricsViewController
        
        popover.contentViewController = lyricsViewController
        popover.contentSize = NSMakeSize(200, 220)
        
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus), name: "com.apple.iTunes.playerInfo", object: nil)
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "com.apple.iTunes.playerInfo")
    }
    
    func iTunesVaryStatus(notification: NSNotification) {
        popover.contentSize = NSMakeSize(200, 220)
        showPopover(popover)
        let destinationViewController = popover.contentViewController as! LyricsViewController
        
        let info = notification.userInfo
        print("user info:\(info)")
        
        let iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes")
        
        print("iTunes:\(iTunes!.running)")
        
        let trackDict = MacUtilities.getCurrentMusicInfo()
        guard let currentArtist = trackDict?.artist, currentTrack = trackDict?.track, currentTime = trackDict?.time else {
                return
        }
        destinationViewController.timeString = currentTime
        
        MusiXMatchApi.getLyrics(currentArtist, track: currentTrack) { (response) in
            
            if response.result.isSuccess {
                
                let trackJSON = JSON(data: response.data!)
                let track = Track.sharedTrack
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if let imageURLString = track.album_coverart_350x350 {
                        
                        destinationViewController.coverImageURL = NSURL(string: imageURLString)
                    }
                    if let lyrics = trackJSON["message"]["body"]["lyrics"]["lyrics_body"].string {
                        destinationViewController.lyrics = lyrics
                    }
                })
            }
        }
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
        
        if popover.shown {
            closePopover(popover)
        } else {
            showPopover(popover)
        }
    }
    
    @IBAction func dockShow(sender: AnyObject) {
        NSApp.setActivationPolicy(.Regular)
    }
    @IBAction func dockHide(sender: AnyObject) {
        NSApp.setActivationPolicy(.Accessory)
    }
}

