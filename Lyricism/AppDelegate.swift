//
//  AppDelegate.swift
//  macOS
//
//  Created by Stan Liu on 16/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

//MARK: To print all the fonts' name
//print(NSFontManager.sharedFontManager().availableFontFamilies.description)

// [Crashlytics Crash] Warning: NSApplicationCrashOnExceptions is not set. This will result in poor top-level uncaught exception reporting.
// https://docs.fabric.io/apple/crashlytics/os-x.html
// NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions": true])

import Cocoa
import SwiftyJSON
import AppKit
import ScriptingBridge
import MediaLibrary
import RealmSwift

import Fabric
import Crashlytics

enum SBApplicationID {
  
  static let sourceKey = "player_source"
  
  case itunes
  case spotify
  
  func values() -> (app: String, playerstate: String) {
    
    switch self {
    case .itunes: return ("com.apple.iTunes", "com.apple.iTunes.playerInfo")
    case .spotify: return ("com.spotify.client", "com.spotify.client.PlaybackStateChanged")
    }
  }
}

@NSApplicationMain
// MARK: Main AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate, PreferencesSetable, DismissTimerable {
  
  static let sharedDelegate = AppDelegate()  
  var window: NSWindow?
  
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
  
  let lyricsPopover = NSPopover()
  let jumpOnLabelPopover = SFPopover()
  
  var eventMonitor: EventMonitor?
  var isiTunesPaused = false
  
  var dismissTimer: NSTimer!
  var dismissTime: Int = 4;
  
  // MARK: NSApplicationDelegate
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    
    // [Crashlytics Crash] Warning: NSApplicationCrashOnExceptions is not set. This will result in poor top-level uncaught exception reporting.
    // https://docs.fabric.io/apple/crashlytics/os-x.html
    NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions": true])
    Fabric.with([Crashlytics.self, Answers.self])
    /*
    Answers.logCustomEventWithName("Video Played", customAttributes: [
      "Category": "Comedy",
      "Length": 350])
    
    Answers.logContentViewWithName("Popup", contentType: "Text", contentId: "1234",
                                   customAttributes: [
                                    "MessageLength": 11,
                                    "MessageText": "Hello World"])
    */
    // Realm Migration
    print("realm path: \(Realm.Configuration.defaultConfiguration.fileURL)")
    
    let config = Realm.Configuration(
      // Set the new schema version. This must be greater than the previously used
      // version (if you've never set a schema version before, the version is 0).
      schemaVersion: 1,
      
      // Set the block which will be called automatically when opening a Realm with
      // a schema version lower than the one set above
      migrationBlock: { migration, oldSchemaVersion in
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
          // Nothing to do!
          // Realm will automatically detect new properties and removed properties
          // And will update the schema on disk automatically
        }
    })
    
    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config
    
    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
    
    
    lyricsPopover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(LyricsViewController)) as! LyricsViewController
    jumpOnLabelPopover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(JumpOnLabelViewController)) as! JumpOnLabelViewController
    
    
    showDock()
    
    // button image on status bar
    if let button = statusItem.button {
      
      button.target = self
      button.image = NSImage(named: "note_dark")
      button.alternateImage = NSImage(named: "note_light")
      button.action = #selector(AppDelegate.showLyrics(_:))
    }
    
    // Detect mouse down event
    eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) {
      [unowned self] event in
      
      if self.lyricsPopover.shown && self.isWindowsOnTop() == false {
        self.lyricsPopover.performClose(self)
      }
    }
    eventMonitor?.start()
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
    
    print("itunes:\(iTunesApp)")
    
    print("spotify:\(spotifyApp)")
    
    NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus(_:)), name: SBApplicationID.itunes.values().playerstate, object: nil)

    
  }
  
  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
    //NSNotificationCenter.defaultCenter().removeObserver(self)
    NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension AppDelegate {
  
  func iTunesSetup() {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    guard let iTunes = iTunesApp.player else {
      
      return
    }
    iTunes.activate()
    iTunes.delegate = self
    
    //NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(iTunesVaryStatus(_:)), name: SBApplicationID.itunes.values().playerstate, object: nil)
  }
  
  func spotifySetup() {
    
    let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
    
    guard let spotify = spotifyApp.player else {
      
      return
    }
    spotify.activate()
    spotify.delegate = self
    
    //NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(spotifyVaryStatus(_:)), name: SBApplicationID.spotify.values().playerstate, object: nil)
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
  
  @IBAction func showDockOption(sender: AnyObject) { setDocker(.yes) }
  @IBAction func hideDockOption(sender: AnyObject) { setDocker(.no) }
}

// MARK: Nofification for iTunes
extension AppDelegate {
  
  func spotifyVaryStatus(notification: NSNotification) {
    
    guard let info = notification.userInfo, playerState = info["Player State"] as? String else {
      
      return
    }
    
    if playerState == "Playing" {
      print("spotify playing")
    } else if playerState == "Stopped" {
      print("spotify stopped")
    } else if playerState == "Paused" {
      print("spotify paused")
    }
  }
  
  func iTunesVaryStatus(notification: NSNotification) {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    guard let iTunes = iTunesApp.player else {
      return
    }
    
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
  
  func playerIsPlaying(name: String, artist: String, time: String) {
    if isiTunesPaused {
      
      if lyricsPopover.shown {
        (lyricsPopover.contentViewController as! LyricsViewController).resumeTimer()
        print("timer resume!")
      }
      isiTunesPaused = false
      print("song keep playing")
    } else {
      // iTunes playing after a "Stop" or "New Song"
      print("new song playing")
      if lyricsPopover.shown {
        
        let track = PlayerTrack(artist: artist, name: name, time: time)
        (self.lyricsPopover.contentViewController as! LyricsViewController).configure(withPresenter: track)
        print("query Music info")
        
      } else if !lyricsPopover.shown {
        
        showJumpOnLabel(artist, trackName: name)
      }
    }
    
  }
  
  func iTunesPlaying() {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    // This is a flag if iTunes playing after a "PAUSE".
    if isiTunesPaused {
      
      if lyricsPopover.shown {
        (lyricsPopover.contentViewController as! LyricsViewController).resumeTimer()
        print("timer resume!")
      }
      isiTunesPaused = false
      print("song keep playing")
    } else {
      // iTunes playing after a "Stop" or "New Song"
      print("new song playing")
      if lyricsPopover.shown {
        
        guard let artist = iTunesApp.track_artist, name = iTunesApp.track_name, time = iTunesApp.track_time else {
          
          return
        }

        let track = PlayerTrack(artist: artist, name: name, time: time)
        (self.lyricsPopover.contentViewController as! LyricsViewController).configure(withPresenter: track)
        print("query Music info")
        
      } else if !lyricsPopover.shown {
        
        guard let artist = iTunesApp.track_artist, name = iTunesApp.track_name, time = iTunesApp.track_time else {
          
          return
        }
        
        showJumpOnLabel(artist, trackName: name)
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
    
    (lyricsPopover.contentViewController as! LyricsViewController).stopTimer()
    
    isiTunesPaused = true
  }
  
  func iTunesStop() {
    
    lyricsPopover.close()
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
        
    self.timerStop()
    
    if self.jumpOnLabelPopover.shown {
      self.jumpOnLabelPopover.close()
    }
    
    if self.lyricsPopover.shown {
      self.lyricsPopover.close()
      
      return
    } else {
      self.lyricsPopover.showRelativeToRect(sender.bounds, ofView: sender as! NSView, preferredEdge: .MinY)
      NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
  }
}

extension AppDelegate: SBApplicationDelegate {
  
  func eventDidFail(event: UnsafePointer<AppleEvent>, withError error: NSError) -> AnyObject {
    
    print("event:\(event) fail: \(error.localizedDescription)")
        
    let i = error.userInfo
    
    let error_brief_message = i["ErrorBriefMessage"]
    let error_expected_type = i["ErrorExpectedType"]
    let error_offending_object = i["ErrorOffendingObject"]
    let error_string = i["ErrorString"]
    let error_number = i["ErrorNumber"]
    
    print("error_brief_message:\(error_brief_message)")
    print("error_expected_type:\(error_expected_type)")
    print("error_offending_object:\(error_offending_object)")
    print("error_string:\(error_string)")
    print("error_number:\(error_number)")
    
    return error.userInfo
  }
}
