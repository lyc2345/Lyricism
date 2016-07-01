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
    let popover = NSPopover()
    
    var eventMonitor: EventMonitor?
    var isiTunesPaused = false
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        showDock()
        
        // button image on status bar
        if let button = statusItem.button {
            button.image = NSImage(named: "light_lyrics")
            button.action = #selector(togglePopover)
        }
        
        let lyricsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("lyrics_view_controller") as! LyricsViewController
        
        popover.contentViewController = lyricsViewController
        popover.contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
        popover.delegate = self
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus), name: "com.apple.iTunes.playerInfo", object: nil)
        
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor?.start()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "com.apple.iTunes.playerInfo")
    }
    
}

extension AppDelegate {
    
    func showDock() {
        let isDockShowed = NSUserDefaults.standardUserDefaults().boolForKey("show_dock_option")
        if isDockShowed {
            NSApp.setActivationPolicy(.Accessory)
        } else {
            NSApp.setActivationPolicy(.Regular)
        }
    }
}

// IBAction for menu
extension AppDelegate {
    
    @IBAction func showDockOption(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "show_dock_option")
        NSApp.setActivationPolicy(.Regular)
    }
    @IBAction func hideDockOption(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "show_dock_option")
        NSApp.setActivationPolicy(.Accessory)
    }
}

/// NSPopover
extension AppDelegate {
    
    func showPopover(sender: AnyObject?) {
        
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        
        if popover.shown {
            closePopover(popover)
        } else {
            showPopover(popover)
        }
    }
}

/// Nofification for iTunes
extension AppDelegate {
    
    func iTunesVaryStatus(notification: NSNotification) {
        
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        
        if iTunes.playerState == iTunesEPlS.Playing {
            print("iTunes playing")
            iTunesPlaying()
            
        } else if iTunes.playerState == iTunesEPlS.Paused {
            print("iTunes Paused")
            iTunesPaused()
            
        } else if iTunes.playerState == iTunesEPlS.Stopped {
            print("iTunes Stopped")
            iTunesStop()
            
        } else if iTunes.playerState == iTunesEPlS.FastForwarding {
            print("iTunes FastForwarding")
            
        } else if iTunes.playerState == iTunesEPlS.Rewinding {
            print("iTunes Rewinding")
            
        } else {
            print("iTunes default")
        }
    }
    
    func iTunesPlaying() {
        
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        print("itunes track playing:\(iTunes.currentTrack?.name!)")
        
        let destinationViewController = popover.contentViewController as! LyricsViewController
        
        if isiTunesPaused {
            
            destinationViewController.resumeTimer()
            isiTunesPaused = false
            print("song keep playing")
        } else {
            print("new song playing")
            queryMusicInfo()
        }
        if popover.shown == false {
            showPopover(popover)
        }
    }
    
    func iTunesPaused() {
        let destinationViewController = popover.contentViewController as! LyricsViewController
        destinationViewController.stopTimer()
        isiTunesPaused = true
    }
    
    func iTunesStop() {
        
        let destinationViewController = popover.contentViewController as! LyricsViewController
        destinationViewController.lyrics = nil
        destinationViewController.artworkURL = nil
        
        closePopover(eventMonitor)
    }
    
    func queryMusicInfo() {
        
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        let lyricsViewController = popover.contentViewController as! LyricsViewController
        
        
        guard let artist = iTunes.currentTrack?.artist, name = iTunes.currentTrack?.name, time = iTunes.currentTrack?.time else {
            return
        }
        // new song playing
        lyricsViewController.timeString = time
        lyricsViewController.marqueeText = "\(artist) - \(name)"
    
        if let artwork = iTunes.currentTrack?.artworks!().firstObject as? NSImage {
            lyricsViewController.imageView.image = artwork
        } else {
            print("No Local Image: \(iTunes.currentTrack?.artworks!().firstObject )")
        }
        
        let track = MusiXTrack(artist: artist, name: name, lyrics: nil, time: time)
        
        MusiXMatchApi.searchLyrics(track) { (success, lyrics) in
            
            self.printLog("lyrics:\(lyrics)")
            lyricsViewController.lyrics = success ? lyrics : nil
        }
    }
}

extension AppDelegate: NSPopoverDelegate {
    
    func popoverDidShow(notification: NSNotification) {
        print("Popover did show")
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        // new song
        if iTunes.currentTrack?.name != Track.sharedTrack.track_name {
            print("Popover did show and new song")
            //queryMusicInfo()
        }
        
        print("iTunes.playerPosition:\(iTunes.playerPosition!)")
    }
    
    func popoverWillShow(notification: NSNotification) {
        
    }
    
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
}