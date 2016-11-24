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
import SwiftyUserDefaults

@NSApplicationMain
// MARK: Main AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate, PlayerGettable, DockerSettable, WindowSettable, Dismissable {
  
  var window: NSWindow?
  
  let statusItem = NSStatusBar.system().statusItem(withLength: -2)
  
  let lyricsPopover = NSPopover()
  let shortPopover = SFPopover()
  
  var eventMonitor: EventMonitor?
  var isPlayerPaused = false
  
  var dismissTimer: Timer!
  var dismissTime: Int = 4
	
	var track: EasyTrack?
	
	var playerSourceWC: SetPlayerSourceWC?
	
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
      schemaVersion:	4,
      
      // Set the block which will be called automatically when opening a Realm with
      // a schema version lower than the one set above
      migrationBlock: { migration, oldSchemaVersion in
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 4) {
          // Nothing to do!
          // Realm will automatically detect new properties and removed properties
          // And will update the schema on disk automatically
        }
    })
    
    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config
    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
		
		userSetup()
		popoverSetup()
		eventMonitorSetup()
		
		playerSourceWC = SetPlayerSourceWC.instantiate(withStoryboard:"Main")
		playerSourceWC?.window?.center()
		playerSourceWC?.window?.styleMask = .titled
		playerSourceWC?.showWindow(self)
		
		if let source = Defaults[.playerSource] {
			switch source {
			case 0:
				iTunesSetup()
			case 1:
				spotifySetup()
			default:
				// TODO: ALert
				print("alert")
			}
		}
		
		guard Defaults[.isTutorialShow] == false else {
      
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
			Defaults[.isTutorialShow] = false
    }
  }
}

extension AppDelegate {

	// MARK: Player Setting
  func iTunesSetup() {
		
		iTunes() { (iTunesApp) in
			
			guard let i = iTunesApp else {
				return
			}
			DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerStateChanged(_:)), name: NSNotification.Name(rawValue: i.identifiers().values().app), object: nil)
			Defaults[.playerSource] = 0
			//iTunes.activate()
			i.unwrap().delegate = self
		}
	}
  
  func spotifySetup() {
		
		spotify() { (spotifyApp) in
			
			guard let s = spotifyApp else {
				return
			}
			DistributedNotificationCenter.default().addObserver(self, selector: #selector(playerStateChanged(_:)), name: NSNotification.Name(rawValue: s.identifiers().values().playerstate), object: nil)
			Defaults[.playerSource] = 1
			//spotify.activate()
			s.unwrap().delegate = self
		}
	}
	
	// MARK: Dock Setting
  func popoverSetup() {
  
		lyricsPopover.contentViewController = LyricVC.instantiate(withStoryboard: "Main")
		shortPopover.contentViewController = HUDVC.instantiate(withStoryboard: "Main") 
    
    // button image on status bar
		guard let button = statusItem.button else {
			return
		}
		button.target = self
		button.action = #selector(showLyrics(_:))
		guard NSAppearance.current().name.hasPrefix("NSAppearanceNameVibrantDark") else {
			
			button.image = NSImage.noteDark
			button.alternateImage = NSImage.noteLight
			return
		}
		button.image = NSImage.noteLight
		button.alternateImage = NSImage.noteDark
	}
	
	func eventMonitorSetup() {
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
  
  func userSetup() {
    
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
		
		iTunes() { (iTunesApp) in
			
			guard let i = iTunesApp, notification.object as? String == i.identifiers().values().player else {
				return
			}
			let app = i.unwrap()
			track = EasyTrack(name: (app.currentTrack?.name)!, artist: (app.currentTrack?.artist!)!, time: (app.currentTrack?.time!)!)
			
			if app.playerState == iTunesEPlS.playing {
				
				Debug.print("iTunes playing")
				playerIsPlaying(.itunes(""), track: track!)
				
			} else if app.playerState == iTunesEPlS.paused {
				Debug.print("iTunes Paused")
				playerPaused()
				
			} else if app.playerState == iTunesEPlS.stopped {
				Debug.print("iTunes Stopped")
				playerStop()
				
			} else if app.playerState == iTunesEPlS.fastForwarding {
				Debug.print("iTunes FastForwarding")
			} else if app.playerState == iTunesEPlS.rewinding {
				Debug.print("iTunes Rewinding")
			} else {
				Debug.print("iTunes default")
			}
		}
		
		spotify() { (spotifyApp) in
			
			guard let s = spotifyApp, let info = notification.userInfo, let playerState = info["Player State"] as? String, let name = info["Name"] as? String, let artist = info["Artist"] as? String, let time = info["Duration"] as? Double, notification.object as? String == s.identifiers().values().app else {
				return
			}
			track = EasyTrack(name: name, artist: artist, time: time)
			
			
			let app = s.unwrap()
			print("spotify playerState:\(app.playerState == SpotifyEPlS.playing)")
			
			if playerState == "Playing" {
				Debug.print("spotify playing")
				
				let milliTime = time / 1000
				let minutes = Int(milliTime / 60)
				let seconds = Int(milliTime.truncatingRemainder(dividingBy: 60))
				let timeString = "\(minutes):\(seconds < 10 ? "0\(seconds)" : "\(seconds)")"
				playerIsPlaying(.spotify(""), track: track!)
				
			} else if playerState == "Paused" {
				Debug.print("spotify paused")
				playerPaused()
				
			} else if playerState == "Stopped" {
				Debug.print("spotify stopped")
				playerStop()
			}
		}
	}
  
	func playerIsPlaying(_ source: App<String>, track: EasyTrack) {
		
		let lyricsVC = lyricsPopover.contentViewController as! LyricVC
		
    if isPlayerPaused {
      
      if lyricsPopover.isShown {
				
        lyricsVC.configure(track: track)
        lyricsVC.resumeTimer()
        Debug.print("timer resume!")
      }
      isPlayerPaused = false
      Debug.print("song keep playing")
    } else {
      // iTunes playing after a "Stop" or "New Song"
      Debug.print("new song playing")
			
      if lyricsPopover.isShown {
        
        lyricsVC.configure(track: track)
        Debug.print("query Music info")
        
      } else if !lyricsPopover.isShown {
        
        showMusicHUD(source, track: track)
      }
    }
  }
  
  func playerPaused() {
    
    (lyricsPopover.contentViewController as! LyricVC).stopTimer()
    
    isPlayerPaused = true
  }
  
  func playerStop() {
    
    lyricsPopover.close()
  }
  
  func showMusicHUD(_ source: App<String>, track: EasyTrack) {
		
		let popoverVC = shortPopover.contentViewController as! HUDVC
    
    if shortPopover.isShown {
      shortPopover.close()
    }
    shortPopover.show(relativeTo: statusItem.button!.frame, of: statusItem.button!, preferredEdge: .minY)
		popoverVC.trackTitle = "\(track.artist) - \(track.name)"
    popoverVC.source = source
    timerStop()
    timerStart()
  }

	func dismissTimerCountDown() {
    
    if let _ = dismissTimer, dismissTime == 0 {
      timerStop()
      shortPopover.close()
      return
    }
    dismissTime -= 1
  }
}

// MARK: NSPopover action
extension AppDelegate {
  
  func showLyrics(_ sender: AnyObject) {
        
    self.timerStop()
    
    if self.shortPopover.isShown {
      self.shortPopover.close()
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
    
    Debug.print("event:\(event) fail: \(error.localizedDescription)")
        
    let i = error.localizedDescription
    /*
    let error_brief_message = i["ErrorBriefMessage"]
    let error_expected_type = i["ErrorExpectedType"]
    let error_offending_object = i["ErrorOffendingObject"]
    let error_string = i["ErrorString"]
    let error_number = i["ErrorNumber"]
    
    Debug.print("error_brief_message:\(error_brief_message)")
    Debug.print("error_expected_type:\(error_expected_type)")
    Debug.print("error_offending_object:\(error_offending_object)")
    Debug.print("error_string:\(error_string)")
    Debug.print("error_number:\(error_number)")*/
		Debug.print(i)
    
    return error
  }
}
