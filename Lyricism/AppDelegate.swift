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
    
    static let sharedDelegate = AppDelegate()
    
    var window: NSWindow?
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    lazy var popover: SFPopover = {
        
        let ppo = SFPopover()
        
        return ppo
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
    
    let iTunes = SwiftyiTunes.sharedInstance.iTunes
    
    // MARK: NSApplicationDelegate
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        //MARK: To print all the fonts' name
        //print(NSFontManager.sharedFontManager().availableFontFamilies.description)
        
        showDock()
    
        // button image on status bar
        if let button = statusItem.button {
            
            button.image = NSImage(named: "note_dark")
            button.alternateImage = NSImage(named: "note_light")
            button.action = #selector(showLyrics)
        }
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus), name: "com.apple.iTunes.playerInfo", object: nil)
        
        // Detect mouse down event
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
            [unowned self] event in
            
            if self.popover.shown && !NSUserDefaults.standardUserDefaults().boolForKey("isAlwaysOnTop") {
                
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

// MARK: IBAction for Left Top Panel Menu option is "Dock"
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

        //print("itunes track playing:\(iTunes.currentTrack?.name!)")
        
        // This is a flag if iTunes playing after a "PAUSE".
        if isiTunesPaused {
            
            if popover.shown && popover.contentViewController is LyricsViewController {
                lyricsViewController.resumeTimer()
            }
            
            isiTunesPaused = false
            print("song keep playing")
        } else {
            
            // iTunes playing after a "Stop" or "New Song"
            print("new song playing")
            
            if popover.shown && popover.contentViewController is LyricsViewController {
                queryMusicInfo()
            } else {
                showJumpOnLabel(iTunes.currentTrack!.artist!, trackName: iTunes.currentTrack!.name!)
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
            //lyricsViewController.lyrics = nil
            //lyricsViewController.artworkURL = nil
        }
        popover.close(nil)
    }
    
    func queryMusicInfo() {
        
        guard let artist = iTunes.currentTrack?.artist, name = iTunes.currentTrack?.name, time = iTunes.currentTrack?.time else {
            
            fatalError("iTunes.currentTrack is nil")
        }
        // use local artwork
        /*
        if let artwork = iTunes.currentTrack?.artworks!().firstObject as? NSImage {
            lyricsViewController.imageView.image = artwork
        } else {
            print("No Local Image: \(iTunes.currentTrack?.artworks!().firstObject )")
        }*/
        var track = MusiXTrack(artist: artist, name: name, lyrics: nil, time: time, artwork: nil)
        
        passLyricsViewController(&track)
    }
    
    func passLyricsViewController(inout track: MusiXTrack) {
        
        self.lyricsViewController.configure(withPresenter: track)
        // why not pass artwork, because it alwasy nil from this musiXmatch api
    }
    
    func showJumpOnLabel(artist: String, trackName: String) {
        
        if popover.shown {
            popover.close(nil)
        }
        popover.show(viewController: jumpOnLabelViewController, at: statusItem.button!, handler: {
            self.jumpOnLabelViewController.trackTitle = "\(artist) - \(trackName)"
        })

        timerStop()
        timerStart()
    }
}

// MARK: NSPopover action
extension AppDelegate {
    
    func showLyrics(sender: AnyObject) {
        
        timerStop()
        
        if popover.shown {
            popover.close(nil)
        } else {
            popover.show(viewController: lyricsViewController, at: sender as! NSView, handler: { () in
                //
            })
        }
    }
    
    func togglePopover() {
    }
}
