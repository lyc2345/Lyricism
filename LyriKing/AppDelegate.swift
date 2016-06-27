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
        
        let info = notification.userInfo
        //print("user info:\(info)")
        
        if info!["Player State"] as! String == "Playing" {
            //print("playing")
            iTunesPlaying()
            
        } else if info!["Player State"] as! String == "Paused" {
            //print("Paused")
            iTunesPaused()
        } else if info!["Player State"] as! String == "Stopped" {
            //print("Stopped")
            iTunesStop()
            
        } else {
            print("else playing status")
        }
        let _ = SBApplication(bundleIdentifier: "com.apple.iTunes")
    }
    
    func iTunesPlaying() {
        if popover.shown == false {
            showPopover(popover)
        }
        let destinationViewController = popover.contentViewController as! LyricsViewController
        if isiTunesPaused {
            
            destinationViewController.resumeTimer()
            isiTunesPaused = false
            print("song keep playing")
        } else {
            print("new song playing")
            let playingTrack = MacUtilities.getCurrentMusicInfo()
            guard let currentArtist = playingTrack?.artist, currentTrack = playingTrack?.track, currentTime = playingTrack?.time else {
                return
            }
            if currentArtist != Track.sharedTrack.artist_name {
                // new song playing
                destinationViewController.timeString = currentTime
                destinationViewController.marqueeText = "\(currentArtist) - \(currentTrack)"
                
                
                MusiXMatchApi.getLyricsNCoverURL(currentArtist, track: currentTrack, completion: { (success, lyrics, coverURL) in
                    
                    if success {
                            
                        if let coverURL = coverURL, let lyrics = lyrics {
                            destinationViewController.coverImageURL = coverURL
                            destinationViewController.lyrics = lyrics
                        }

                    }
                })
            }  else {
                // no new song playing
                print("no new song playing")
            }
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
        destinationViewController.coverImageURL = nil
        
        closePopover(eventMonitor)
    }
}

extension AppDelegate: NSPopoverDelegate {
    
    func popoverDidShow(notification: NSNotification) {
        
    }
    
    func popoverWillShow(notification: NSNotification) {
        
    }
    
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
}