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
  
  func values() -> (app: String, playerstate: String, player: String) {
    
    switch self {
    case .itunes: return ("com.apple.iTunes", "com.apple.iTunes.playerInfo", "com.apple.iTunes.player")
    case .spotify: return ("com.spotify.client", "com.spotify.client.PlaybackStateChanged", "com.spotify.client")
    }
  }
}

@NSApplicationMain
// MARK: Main AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate, DockerSettable, WindowSettable, Dismissable {
  
  var window: NSWindow?
  
  let statusItem = NSStatusBar.system().statusItem(withLength: -2)
  
  let lyricsPopover = NSPopover()
  let popoverVC = SFPopover()
  
  var eventMonitor: EventMonitor?
  var isPlayerPaused = false
  
  var dismissTimer: Timer!
  var dismissTime: Int = 4;
  
  // MARK: NSApplicationDelegate
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // [Crashlytics Crash] Warning: NSApplicationCrashOnExceptions is not set. This will result in poor top-level uncaught exception reporting.
    // https://docs.fabric.io/apple/crashlytics/os-x.html
    UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
    Fabric.with([Crashlytics.self, Answers.self])

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
    
    userSetting()
    appSetting()
		initailEventMonitor()

    iTunesSetup()
    spotifySetup()
    
    guard UserDefaults.standard.bool(forKey: "tutorial_keep_remind") == false else {
      
      showTutorial()
      return
    }
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    
    DistributedNotificationCenter.default().removeObserver(self)
  }
  
  func showTutorial() {
    
    let alert = NSAlert()
    alert.messageText = "Tutorial"
    alert.informativeText = "Lyricism is a lyrics plugin with Your iTunes or Spotify. \n\nPlay, Lyric and Sing!"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "I know")
    alert.addButton(withTitle: "Don't Remind me!")
    let res = alert.runModal()
    
    if res == NSAlertFirstButtonReturn {
    } else {
      UserDefaults.standard.set(false, forKey: "tutorial_keep_remind")
    }
  }
}

extension AppDelegate {
  
  func iTunesSetup() {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerStateChanged(_:)), name: NSNotification.Name(rawValue: SBApplicationID.itunes.values().playerstate), object: nil)
    s_print("itunes:\(iTunesApp)")
    
    guard let i = iTunesApp.player else {
      
      return
    }
    //iTunes.activate()
    guard i.running else {
      return
    }
    i.delegate = self
  }
  
  func spotifySetup() {
    
    let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
    DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerStateChanged(_:)), name: NSNotification.Name(rawValue: SBApplicationID.spotify.values().playerstate), object: nil)
    sd_print("spotify:\(spotifyApp)")
    
    guard let s = spotifyApp.player else {
      
      return
    }
    //spotify.activate()
    guard s.running else {
      return
    }
    s.delegate = self
  }
}

// MARK: Dock Setting
extension AppDelegate {
  
  func appSetting() {
  
    lyricsPopover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: String(describing: LyricsVC.self)) as! LyricsVC
    popoverVC.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: String(describing: PopoverVC.self)) as! PopoverVC
    
    // button image on status bar
    if let button = statusItem.button {
      button.target = self
      button.action = #selector(showLyrics(_:))
      guard NSAppearance.current().name.hasPrefix("NSAppearanceNameVibrantDark") else {
        
        button.image = NSImage(named: "note_dark")
        button.alternateImage = NSImage(named: "note_light")
        return
      }
      button.image = NSImage(named: "note_light")
      button.alternateImage = NSImage(named: "note_dark")
      
    }
	}
	
	func initailEventMonitor() {
    // Detect mouse down event
    eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) {
      [unowned self] event in
      
      guard self.lyricsPopover.isShown && self.isWindowsOnTop() else {
        
        return
      }
      self.lyricsPopover.performClose(self)
    }
    eventMonitor?.start()
  }
  
  func userSetting() {
    
    isDockerShown() ? setDocker(.yes) : setDocker(.no)
  }
}

// MARK: IBAction for Left Top Panel Menu option is "Dock"
extension AppDelegate {
  
  @IBAction func showDockOption(_ sender: AnyObject) { setDocker(.yes) }
  @IBAction func hideDockOption(_ sender: AnyObject) { setDocker(.no) }
}

// MARK: Nofification for iTunes
extension AppDelegate {
  
  func playerStateChanged(_ notification: Notification) {
    
    s_print("notification:\(notification)")
    
    guard notification.object as? String == SBApplicationID.itunes.values().player  else {
      
      guard let info = notification.userInfo, let playerState = info["Player State"] as? String, let name = info["Name"] as? String, let artist = info["Artist"] as? String, let time = info["Duration"] as? Double, notification.object as? String == SBApplicationID.spotify.values().app else {
        
        return
      }
      
      let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
      
      print("spotify playerState:\(spotifyApp.player!.playerState == SpotifyEPlS.playing)")
      
      if playerState == "Playing" {
        s_print("spotify playing")
        
        let milliTime = time / 1000
        let minutes = Int(milliTime / 60)
        let seconds = Int(milliTime.truncatingRemainder(dividingBy: 60))
        let timeString = "\(minutes):\(seconds < 10 ? "0\(seconds)" : "\(seconds)")"
        playerIsPlaying(.spotify, name: name, artist: artist, time: timeString)
        
      } else if playerState == "Paused" {
        s_print("spotify paused")
        playerPaused()
        
      } else if playerState == "Stopped" {
        s_print("spotify stopped")
        playerStop()
      }
      return
    }
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    if iTunesApp.player!.playerState == iTunesEPlS.playing {
      
      s_print("iTunes playing")
      playerIsPlaying(.itunes, name: iTunesApp.track_name!, artist: iTunesApp.track_artist!, time: iTunesApp.track_time!)
      
    } else if iTunesApp.player!.playerState == iTunesEPlS.paused {
      s_print("iTunes Paused")
      playerPaused()
      
    } else if iTunesApp.player!.playerState == iTunesEPlS.stopped {
      s_print("iTunes Stopped")
      playerStop()
      
    } else if iTunesApp.player!.playerState == iTunesEPlS.fastForwarding {
      s_print("iTunes FastForwarding")
    } else if iTunesApp.player!.playerState == iTunesEPlS.rewinding {
      s_print("iTunes Rewinding")
    } else {
      s_print("iTunes default")
    }
  }
  
  func playerIsPlaying(_ source: SBApplicationID, name: String, artist: String, time: String) {
    
    let track = PlayerTrack(artist: artist, name: name, time: time)
    
    if isPlayerPaused {
      
      if lyricsPopover.isShown {
        
        (self.lyricsPopover.contentViewController as! LyricsVC).configure(withPresenter: track)
        (lyricsPopover.contentViewController as! LyricsVC).resumeTimer()
        s_print("timer resume!")
      }
      isPlayerPaused = false
      s_print("song keep playing")
    } else {
      // iTunes playing after a "Stop" or "New Song"
      s_print("new song playing")
      if lyricsPopover.isShown {
        
        (self.lyricsPopover.contentViewController as! LyricsVC).configure(withPresenter: track)
        s_print("query Music info")
        
      } else if !lyricsPopover.isShown {
        
        showMusicHUD(source, track: track)
      }
    }
    
  }
  
  func playerPaused() {
    
    (lyricsPopover.contentViewController as! LyricsVC).stopTimer()
    
    isPlayerPaused = true
  }
  
  func playerStop() {
    
    lyricsPopover.close()
  }
  
  func showMusicHUD(_ source: SBApplicationID, track: PlayerTrack) {
    
    if popoverVC.isShown {
      popoverVC.close()
    }
    popoverVC.show(relativeTo: statusItem.button!.frame, of: statusItem.button!, preferredEdge: .minY)
		(popoverVC.contentViewController as! PopoverVC).trackTitle = "\(track.artist) - \(track.name)"
    (popoverVC.contentViewController as! PopoverVC).source = source
    timerStop()
    timerStart()
  }

  func dismissTimerCountDown() {
    
    if let _ = dismissTimer, dismissTime == 0 {
      timerStop()
      popoverVC.close()
      return
    }
    dismissTime -= 1
  }
}

// MARK: NSPopover action
extension AppDelegate {
  
  func showLyrics(_ sender: AnyObject) {
        
    self.timerStop()
    
    if self.popoverVC.isShown {
      self.popoverVC.close()
    }
    
    if self.lyricsPopover.isShown {
      self.lyricsPopover.close()
      
      return
    } else {
      self.lyricsPopover.show(relativeTo: sender.bounds, of: sender as! NSView, preferredEdge: .minY)
      //NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
  }
}

extension AppDelegate: SBApplicationDelegate {
  
  func eventDidFail(_ event: UnsafePointer<AppleEvent>, withError error: Error) -> Any? {
    
    s_print("event:\(event) fail: \(error.localizedDescription)")
        
    let i = error.localizedDescription
    /*
    let error_brief_message = i["ErrorBriefMessage"]
    let error_expected_type = i["ErrorExpectedType"]
    let error_offending_object = i["ErrorOffendingObject"]
    let error_string = i["ErrorString"]
    let error_number = i["ErrorNumber"]
    
    s_print("error_brief_message:\(error_brief_message)")
    s_print("error_expected_type:\(error_expected_type)")
    s_print("error_offending_object:\(error_offending_object)")
    s_print("error_string:\(error_string)")
    s_print("error_number:\(error_number)")*/
		s_print(i)
    
    return error
  }
}
