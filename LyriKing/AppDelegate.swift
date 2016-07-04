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
// MARK: Main AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    lazy var popoverLyrics: NSPopover = {
        
        let popover = NSPopover()
        popover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("lyrics_view_controller") as! LyricsViewController
        popover.contentSize = CGSizeMake(350, 350)
        popover.contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
        popover.delegate = self
        return popover
    }()
    
    lazy var popoverPrompt: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("notification_label_view_controller") as! JumpOnLabelViewController
        popover.contentSize = CGSizeMake(300, 25)
        popover.contentViewController?.view.autoresizingMask = NSAutoresizingMaskOptions([.ViewMaxXMargin, .ViewMaxYMargin]);
        popover.delegate = self
        return popover
    }()
    
    var eventMonitor: EventMonitor?
    var isiTunesPaused = false
    
    var dismissTimer: NSTimer!
    var dismissTime: NSTimeInterval = 3;
    
    var isAlwaysOnTop: Bool {
        
        return NSUserDefaults.standardUserDefaults().boolForKey("isAlwaysOnTop")
    }
    
    // MARK: NSApplicationDelegate
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        showDock()
        
        //NSUserDefaults.standardUserDefaults().registerDefaults(["isAlwaysOnTop": true])
        /*
        let window = NSApplication.sharedApplication().windows.first
        
        if isAlwaysOnTop {
            
            window!.level = Int(CGWindowLevelForKey(.ScreenSaverWindowLevelKey))
        } else {
            window!.level = Int(CGWindowLevelForKey(.NormalWindowLevelKey))
        }*/
        
        // button image on status bar
        if let button = statusItem.button {
            
            button.image = NSImage(named: "note_dark")
            button.alternateImage = NSImage(named: "note_light")
            button.action = #selector(togglePopover)
        }
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus), name: "com.apple.iTunes.playerInfo", object: nil)
        
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            if self.popoverLyrics.shown {
                //self.closePopover(event)
                if self.isAlwaysOnTop {
                    
                } else {
                    self.closePopover(self.popoverLyrics)
                }
            }
        }
        eventMonitor?.start()
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        
        return .TerminateNow
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
// MARK: Dock Setting
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

// MARK: IBAction for menu option is Dock
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

// MARK: NSPopover action
extension AppDelegate {
    
    func showPopover(sender: AnyObject?) {
        
        guard let button = statusItem.button else{
            return
        }
        print("show popover")
        (sender as! NSPopover).showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MaxY)
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        print("close popover")
        if (sender as? NSPopover) == popoverLyrics {
            popoverLyrics.performClose(sender)
        } else {
            popoverPrompt.performClose(sender)
        }
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        
        if popoverLyrics.shown {
            closePopover(popoverLyrics)
        } else {
            closePopover(popoverPrompt)
            showPopover(popoverLyrics)
        }
    }
}

// MARK: Nofification for iTunes
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
        //print("itunes track playing:\(iTunes.currentTrack?.name!)")
        
        if isiTunesPaused {
            if popoverLyrics.shown {
                (popoverLyrics.contentViewController as! LyricsViewController).resumeTimer()
            }
            isiTunesPaused = false
            print("song keep playing")
        } else {
            print("new song playing")
            
            if !popoverLyrics.shown {
                showPopover(popoverPrompt)
                (popoverPrompt.contentViewController as! JumpOnLabelViewController).trackTitle =
                    "\(iTunes.currentTrack!.artist!) - \(iTunes.currentTrack!.name!)"
                timerStop()
                timerStart()
            } else {
                queryMusicInfo()
            }
        }
    }
    
    func dismissTimerCountDown() {
        
        if let _ = dismissTimer where dismissTime == 0 {
            timerStop()
            popoverPrompt.close()
            return
        }
        dismissTime -= 1
    }
    
    func timerStop() {
        if let timer = dismissTimer {
            timer.invalidate()
            dismissTimer = nil
            dismissTime = 4
        }
    }
    
    func timerStart() {
        
        guard let timer = dismissTimer else {
            dismissTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(dismissTimerCountDown), userInfo: nil, repeats: true)
            return
        }
        timer.invalidate()
        dismissTimer = nil
    }
    
    func iTunesPaused() {
        if popoverLyrics.contentViewController is LyricsViewController {
            (popoverLyrics.contentViewController as! LyricsViewController).stopTimer()
        }
        isiTunesPaused = true
    }
    
    func iTunesStop() {
        
        if popoverLyrics.contentViewController is LyricsViewController {
            (popoverLyrics.contentViewController as! LyricsViewController).lyrics = nil
            (popoverLyrics.contentViewController as! LyricsViewController).artworkURL = nil
        }
        
        closePopover(popoverLyrics)
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
        
        if popoverLyrics.shown == false {
            showPopover(popoverLyrics)
        }
        
        if let lyricsViewController = popoverLyrics.contentViewController as? LyricsViewController {
            lyricsViewController.timeString = track.time
            lyricsViewController.marqueeText = "\(track.artist) - \(track.name)"
            lyricsViewController.lyrics = track.lyrics
        }
    }
}
// MARK: NSPopoverDelegate
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
        
        
    }
}