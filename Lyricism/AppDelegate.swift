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
class AppDelegate: NSObject, NSApplicationDelegate, PreferencesSetable, DismissTimerable {
  
  static let sharedDelegate = AppDelegate()
  
  var window: NSWindow?
  
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
  
  //var popoverContainer: SFPopoverContainer!
  
  let lyricsPopover = NSPopover()
  let jumpOnLabelPopover = SFPopover()
  
  var lyricsViewController: LyricsViewController {
    
    return NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(LyricsViewController)) as! LyricsViewController
  }
  
  var jumpOnLabelViewController: JumpOnLabelViewController {
    
    return NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(JumpOnLabelViewController)) as! JumpOnLabelViewController
  }
  
  var eventMonitor: EventMonitor?
  var isiTunesPaused = false
  
  var dismissTimer: NSTimer!
  var dismissTime: Int = 4;
  
  var statusButton: NSButton!
  
  let iTunes = SwiftyiTunes.sharedInstance.iTunes
  
  // MARK: NSApplicationDelegate
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    
    //MARK: To print all the fonts' name
    //print(NSFontManager.sharedFontManager().availableFontFamilies.description)
    
    lyricsPopover.contentViewController = lyricsViewController
    jumpOnLabelPopover.contentViewController = jumpOnLabelViewController
    
    showDock()
    
    // button image on status bar
    if let button = statusItem.button {
      
      button.image = NSImage(named: "note_dark")
      button.alternateImage = NSImage(named: "note_light")
      button.action = #selector(AppDelegate.showLyrics(_:))
    }
    
    NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus), name: "com.apple.iTunes.playerInfo", object: nil)
    
    // Detect mouse down event
    eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
      [unowned self] event in
      
      if self.lyricsPopover.shown && !self.isWindowsOnTop() {
        self.lyricsPopover.performClose(self)
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
    
    isDockerShown() ? setDocker(.yes) : setDocker(.no)
  }
}

// MARK: IBAction for Left Top Panel Menu option is "Dock"
extension AppDelegate {
  
  @IBAction func showDockOption(sender: AnyObject) {
    
    setDocker(.yes)
  }
  @IBAction func hideDockOption(sender: AnyObject) {
    setDocker(.no)
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
      
      if lyricsPopover.shown && lyricsPopover.contentViewController is LyricsViewController {
        (lyricsPopover.contentViewController as! LyricsViewController).resumeTimer()
      }
      
      isiTunesPaused = false
      print("song keep playing")
    } else {
      
      // iTunes playing after a "Stop" or "New Song"
      print("new song playing")
      
      if lyricsPopover.shown && lyricsPopover.contentViewController is LyricsViewController {
        queryMusicInfo()
      } else {
        showJumpOnLabel(iTunes.currentTrack!.artist!, trackName: iTunes.currentTrack!.name!)
      }
    }
  }
  
  func dismissTimerCountDown() {
    
    if let _ = dismissTimer where dismissTime == 0 {
      timerStop()
      jumpOnLabelPopover.close()
      return
    }
    dismissTime -= 1
  }
  
  func iTunesPaused() {
    
    if lyricsPopover.contentViewController is LyricsViewController {
      (lyricsPopover.contentViewController as! LyricsViewController).stopTimer()
    }
    isiTunesPaused = true
  }
  
  func iTunesStop() {
    
    if lyricsPopover.contentViewController is LyricsViewController {
      //lyricsViewController.lyrics = nil
      //lyricsViewController.artworkURL = nil
    }
    lyricsPopover.close()
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
    
    (lyricsPopover.contentViewController as! LyricsViewController).configure(withPresenter: track)
    // why not pass artwork, because it alwasy nil from this musiXmatch api
  }
  
  func showJumpOnLabel(artist: String, trackName: String) {
    
    if jumpOnLabelPopover.shown {
      jumpOnLabelPopover.close()
    }
    
    jumpOnLabelPopover.showRelativeToRect(statusItem.button!.frame, ofView: statusItem.button!, preferredEdge: .MinY)

    (jumpOnLabelPopover.contentViewController as! JumpOnLabelViewController).trackTitle = "\(artist) - \(trackName)"
    
    timerStop()
    timerStart()
  }
}

// MARK: NSPopover action
extension AppDelegate {
  
  func showLyrics(sender: AnyObject) {
    
    timerStop()
    
    if lyricsPopover.shown {
      lyricsPopover.close()
      return
    } else {
      
      lyricsPopover.showRelativeToRect(sender.bounds, ofView: sender as! NSView, preferredEdge: .MinY)
    }
  }
  
  func togglePopover() {
  }
}
