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
    
    lazy var popover: SFPopover = {
        
        return SFPopover()
    }()
    
    lazy var lyricsViewController = {
        
       return NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(LyricsViewController)) as! LyricsViewController
    }()
    
    lazy var jumpOnLabelViewController = {
        
        return NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(JumpOnLabelViewController)) as! JumpOnLabelViewController
    }()
    
    var eventMonitor: EventMonitor?
    var isiTunesPaused = false
    
    var dismissTimer: NSTimer!
    var dismissTime: NSTimeInterval = 4;
    
    var statusButton: NSButton!
    
    
    // MARK: NSApplicationDelegate
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        /// To print all the fonts' name
        //print(NSFontManager.sharedFontManager().availableFontFamilies.description)
        
        showDock()
    
        // button image on status bar
        if let button = statusItem.button {
            
            button.image = NSImage(named: "note_dark")
            button.alternateImage = NSImage(named: "note_light")
            button.action = #selector(showLyrics)
            statusButton = button
        }
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus), name: "com.apple.iTunes.playerInfo", object: nil)
        
        // Detect mouse down event
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            
            if self.popover.shown {
                
                self.popover.close(nil)
            }
        }
        eventMonitor?.start()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "com.apple.iTunes.playerInfo")
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
            
            if popover.shown && popover.contentViewController is LyricsViewController {
                lyricsViewController.resumeTimer()
            }
            
            isiTunesPaused = false
            print("song keep playing")
        } else {
            print("new song playing")
            
            if !popover.shown {
                
                showJumpOnLabel("\(iTunes.currentTrack!.artist!) - \(iTunes.currentTrack!.name!)")
                
            } else if popover.shown && popover.contentViewController is LyricsViewController {
                
                queryMusicInfo()
                
            } else if popover.shown && popover.contentViewController is JumpOnLabelViewController {
                
                showJumpOnLabel("\(iTunes.currentTrack!.artist!) - \(iTunes.currentTrack!.name!)")
            }
        }
    }
    
    func dismissTimerCountDown() {
        
        if let _ = dismissTimer where dismissTime == 0 {
            timerStop()
            popover.close(nil)
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
        
        if popover.contentViewController is LyricsViewController {
            lyricsViewController.stopTimer()
        }
        isiTunesPaused = true
    }
    
    func iTunesStop() {
        
        if popover.contentViewController is LyricsViewController {
            lyricsViewController.lyrics = nil
            lyricsViewController.artworkURL = nil
        }
        
        popover.close(nil)
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
        
        let track = MusiXTrack(artist: artist, name: name, lyrics: nil, time: time, artwork: nil)
        
        MusiXMatchApi.searchLyrics(track) { (success, lyrics) in
            
            self.printLog("lyrics:\(lyrics)")
            let track  = MusiXTrack(artist: artist, name: name, lyrics: lyrics, time: time, artwork: nil)
            self.passLyricsViewController(track)
        }
    }
    
    func passLyricsViewController(track: MusiXTrack) {
    
        if popover.shown == false {
            popover.show(lyricsViewController, at: statusButton, handler: { () in
            })
        } else {
            popover.contentViewController = lyricsViewController
        }
        self.lyricsViewController.timeString = track.time
        self.lyricsViewController.marqueeText = "\(track.artist) - \(track.name)"
        self.lyricsViewController.lyrics = track.lyrics
        self.eventMonitor?.start()
    }
    
    func showJumpOnLabel(title: String) {
        
        if popover.shown {
            popover.close(nil)
            popover.show(jumpOnLabelViewController, at: statusButton, handler: { () in
                self.jumpOnLabelViewController.trackTitle = title
            })
        } else {
            popover.show(jumpOnLabelViewController, at: statusButton, handler: { () in
                self.jumpOnLabelViewController.trackTitle = title
            })
        }
        timerStop()
        timerStart()
    }
}

// MARK: NSPopover action
extension AppDelegate {
    
    func showLyrics() {
        
        timerStop()
        
        if popover.shown {
            popover.close(nil)
        } else {
            popover.show(lyricsViewController, at: statusButton, handler: { () in
                self.eventMonitor?.start()
            })
        }
    }
    
    func togglePopover() {
    }
}