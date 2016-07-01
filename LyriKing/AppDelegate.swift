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
    
    var lyricsShown: Bool {
        
        get {
            return popoverViewController is LyricsViewController
        }
        
        set {
            if lyricsShown {
                popoverViewController = lyricsViewController
            } else {
                popoverViewController = jumpOnLabelViewController
            }
        }
    }
    
    var popoverViewController: NSViewController? {
        
        didSet {
            
            if popoverViewController is JumpOnLabelViewController {
                popover.contentSize = CGSizeMake(300, 35)
                popover.contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewMaxXMargin, .ViewMaxYMargin]);
            }
            if popoverViewController is LyricsViewController{
                popover.contentSize = CGSizeMake(350, 350)
                popover.contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
                
                if dismissTimer != nil {
                    dismissTimer.invalidate()
                    dismissTimer = nil
                }
            }
            self.popover.contentViewController = popoverViewController
        }
    }
    
    var jumpOnLabelViewController: JumpOnLabelViewController! {
        
        didSet {
            print("jumpOnLabelViewController:\(popover.contentSize)")
        }
    }
    var lyricsViewController: LyricsViewController! {
        didSet {
            print("lyricsViewController:\(popover.contentSize)")
        }
    }
    
    var dismissTimer: NSTimer!
    var dismissTime: NSTimeInterval = 3;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        showDock()
        
        // button image on status bar
        if let button = statusItem.button {
            button.image = NSImage(named: "light_lyrics")
            button.action = #selector(togglePopover)
        }
        lyricsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("lyrics_view_controller") as! LyricsViewController
        
        jumpOnLabelViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("notification_label_view_controller") as! JumpOnLabelViewController
        
        popoverViewController = jumpOnLabelViewController
        
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
        
        print("show popover")
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MaxY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        print("close popover")
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        
        if popover.shown {
            //popover.close()
            if popoverViewController is JumpOnLabelViewController {
                
                popoverViewController = lyricsViewController
                //showPopover(popover)
            } else {
                popoverViewController = jumpOnLabelViewController
                popover.close()
            }
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
        
        if isiTunesPaused {
            if popover.contentViewController is LyricsViewController {
                (popover.contentViewController as! LyricsViewController).resumeTimer()
            }
            isiTunesPaused = false
            print("song keep playing")
        } else {
            print("new song playing")
            
            if popover.shown == false {
                showPopover(popover)
            }
            
            if !lyricsShown {
                popoverViewController = jumpOnLabelViewController
                (popover.contentViewController as! JumpOnLabelViewController).trackTitle =
                    "\(iTunes.currentTrack!.artist!) - \(iTunes.currentTrack!.name!)"
                
                dismissTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(dismissLabel), userInfo: nil, repeats: true)
            } else {
                queryMusicInfo()
            }
        }
    }
    
    func dismissLabel() {
        
        if let timer = dismissTimer where dismissTime == 0 {
            timer.invalidate()
            dismissTimer = nil
            popover.close()
        }
        dismissTime -= 1
    }
    
    func iTunesPaused() {
        if popover.contentViewController is LyricsViewController {
            (popover.contentViewController as! LyricsViewController).stopTimer()
        }
        isiTunesPaused = true
    }
    
    func iTunesStop() {
        
        if popover.contentViewController is LyricsViewController {
            (popover.contentViewController as! LyricsViewController).lyrics = nil
            (popover.contentViewController as! LyricsViewController).artworkURL = nil
        }
        
        closePopover(eventMonitor)
    }
    
    func queryMusicInfo() {
        
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        
        guard let artist = iTunes.currentTrack?.artist, name = iTunes.currentTrack?.name, time = iTunes.currentTrack?.time else {
            return
        }
        // new song playing
        /*
        if let artwork = iTunes.currentTrack?.artworks!().firstObject as? NSImage {
            lyricsViewController.imageView.image = artwork
        } else {
            print("No Local Image: \(iTunes.currentTrack?.artworks!().firstObject )")
        }*/
        
        let track = MusiXTrack(artist: artist, name: name, lyrics: nil, time: time)
        
        MusiXMatchApi.searchLyrics(track) { (success, lyrics) in
            
            self.printLog("lyrics:\(lyrics)")
            let track  = MusiXTrack(artist: artist, name: name, lyrics: lyrics, time: time)
            self.passLyricsViewController(track)
        }
    }
    
    func passLyricsViewController(track: MusiXTrack) {
        
        lyricsViewController.timeString = track.time
        lyricsViewController.marqueeText = "\(track.artist) - \(track.name)"
        lyricsViewController.lyrics = track.lyrics
    }
}

extension AppDelegate: NSPopoverDelegate {
    
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
        
        lyricsShown = false
    }
}