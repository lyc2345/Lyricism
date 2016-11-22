//
//  LyricsViewController.swift
//  macOS
//
//  Created by Stan Liu on 17/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import ScriptingBridge
import AVFoundation
import RealmSwift
import ProgressKit

struct EasyTrack {
	
	typealias T = Any
	var name: String
	var artist: String
	var time: T
}

class LyricsVC: NSViewController, MusicTimerable, DockerSettable, WindowSettable, PlayerSourceable {
	
	// Model
  fileprivate var lyric: String? {
    didSet {
      guard let textView = scrollTextView.contentView.documentView as? NSTextView else { return }
      textView.string = self.lyric?.applyLyricsFormat() ?? ""
    }
  }
  
  fileprivate var imageData: Data? {
    didSet {
      guard let data = imageData else { return }
      imageView.image = NSImage(data: data)
    }
  }
	
	// View
  @IBOutlet weak var spinnerProgress: Spinner!
  @IBOutlet weak var controlPanel: NSView!
  @IBOutlet weak var sourceImageView: NSImageView! { didSet { sourceImageView.alphaValue = 0.4 } }
  @IBOutlet weak var timeLabel: NSTextField! { didSet { timeLabel.font = NSFont.fontForTimer() } }
  @IBOutlet weak var trackNameArtistLabel: MarqueeView!
  @IBOutlet weak var imageView: NSImageView!
  @IBOutlet weak var scrollTextView: NSScrollView! {
    didSet {
      guard let textView = scrollTextView.contentView.documentView as? NSTextView else { return }
      textView.font = NSFont.fontForLyricDisplay()
      textView.alignment = .center
      textView.textColor = NSColor.white
    }
  }
  fileprivate var traigleView: NSView?
	
  // protocol Timerable
  var timer: Timer?
  var trackTime: Int!
  
  // This one just for 
	var track: EasyTrack? {
		didSet {
			self.trackNameArtistLabel.text = "\(track?.artist ?? "") - \(track?.name ?? "")"
		}
	}
  
  @IBOutlet weak var isAlwaysOnTop: NSMenuItem!
  @IBOutlet var settingMenu: NSMenu!
  fileprivate var trackingArea: NSTrackingArea!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    traigleView = PopoverContentView(frame: view.frame)
    view.addSubview(traigleView!)
    createTrackingArea()
    
    NotificationCenter.default.addObserver(self, selector: #selector(setSourceImage(_:)), name: NSNotification.Name(rawValue: SBApplicationID.sourceKey), object: nil)
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
   
    showCurrentPlaying()
  }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func iTunes(handler: (App<iTunesApplication>?) -> Void) {
		
		guard let itunesApp = SBApplication(bundleIdentifier: App.itunes(iTunesApplication.self).identifier().app) as? iTunesApplication else {
			
			return
		}
		handler(.itunes(itunesApp))
	}
	
	func spotify(handler: (App<SpotifyApplication>?) -> Void) {
		
		guard let spotifyApp = SBApplication(bundleIdentifier: App.spotify(SpotifyApplication.self).identifier().app) as? SpotifyApplication else {
			
			return
		}
		handler(.spotify(spotifyApp))
	}
	
  func showCurrentPlaying() {
		
		iTunes() { (iTunesApp) in
			
			Debug.print("itunes is running \(iTunesApp?.spirit().running)")
			
			guard let i = iTunesApp?.spirit(), i.running && i.playerState == .playing else {
				
				return
			}
			NotificationCenter.default.post(name: Notification.Name(rawValue: SBApplicationID.sourceKey), object: App.itunes(iTunesApplication.self).identifier().app)
			
			let track = EasyTrack(name: i.currentTrack!.name!, artist: i.currentTrack!.artist!, time: i.currentTrack!.time!)
			configure(track: track)
			Debug.print("itunes  get current playing information:\(iTunesApp)")

		}
		
		spotify() { (spotifyApp) in
		
			Debug.print("spotify is running \(spotifyApp?.spirit().running)")
			guard let s = spotifyApp?.spirit(), s.running else {
				
				// TODO: Show alert to remind user to open one of players
				// TODO: Spotify cant detect...fuck
				/*
				let alert = NSAlert()
				alert.messageText = "NOT Detect iTunes or Spotify are running"
				alert.informativeText = "Lyricism needs you to open your iTunes or Spotify"
				alert.alertStyle = .WarningAlertStyle
				alert.addButtonWithTitle("iTunes")
				alert.addButtonWithTitle("Spotify")
				alert.addButtonWithTitle("Cancel")
				let res = alert.runModal()
				if res == NSAlertFirstButtonReturn {
				iTunesApp.player?.activate()
				} else if res == NSAlertSecondButtonReturn {
				spotifyApp.player?.activate()
				} else {
				// do nothing
				}*/
				
				return
			}
			NotificationCenter.default.post(name: Notification.Name(rawValue: SBApplicationID.sourceKey), object: App.spotify(SpotifyApplication.self).identifier().app)
			
			let track = EasyTrack(name: s.currentTrack!.name!, artist: s.currentTrack!.artist!, time: String(describing: s.currentTrack!.duration!))

			configure(track: track)
			Debug.print("spotify get current playing information:\(spotifyApp)")
		}
	}
	
  // PlayerSourceable Delegate
  func setSourceImage(_ notification: Notification) {
    
    guard let source = notification.object as? String else {
      
      return
    }
    DispatchQueue.main.async { 
      
      switch source {
      case App.itunes(iTunesApplication.self).identifier().app: self.sourceImageView.image = NSImage(named: "iTunes")
      case App.spotify(SpotifyApplication).identifier().app: self.sourceImageView.image = NSImage(named: "spotify")
      default:
        fatalError("out of SBApplicationID type")
      }
    }
  }
	
	func configure(track: EasyTrack) {
		
		print("time: \(track.time)")
		spinnerProgress.animate = true
		trackTime = currentTimeFromString(track.time as? String ?? "0")
		
		guard let realm_track = SFRealm.query(name: track.name, t: Track.self)?.first else {
			Debug.print("realm_track is nil")
			searchLyricNArtwork(track)
			return
		}
		trackTime = currentTimeFromInt(realm_track.time) { (time) in
			
		}
		
		spinnerProgress.animate = false
		
		guard let realm_lyric = realm_track.lyric else {
			Debug.print("lyric is nil")
			searchLyricNArtwork(track)
			return
		}
		lyric = realm_lyric.text
		
		
		guard let realm_album = realm_track.album, let artwork_data = realm_album.artwork else {
			searchLyricNArtwork(track)
			Debug.print("realm_album is nil")
			return
		}
		
		imageData = artwork_data as Data
	}
	
  func searchLyricNArtwork(_ track: EasyTrack) {
    
    MusiXMatchApi.searchLyrics(track.artist, trackName: track.name){ (success, lyric, imageData) in
      
      DispatchQueue.main.async(execute: {
        self.spinnerProgress.animate = false
      })
			
			guard success == true else {
				Debug.print("request is failured!")
				return
			}
      
      DispatchQueue.main.async(execute: {
				
        self.lyric = lyric
				self.imageData = imageData
      })
		}
  }
  
  func createTrackingArea() {
    
    if trackingArea != nil {
      view.removeTrackingArea(trackingArea)
    }
    let circleRect = view.bounds
    let flag = NSTrackingAreaOptions.mouseEnteredAndExited.rawValue + NSTrackingAreaOptions.activeAlways.rawValue
    trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
    view.addTrackingArea(trackingArea)
    hideControlPanel()
  }
  
  @IBAction func alwaysOnTopBtnPressed(_ sender: AnyObject) {
    
    isAlwaysOnTop.attributedTitle = NSAttributedString(string: !isWindowsOnTop() ? NSLocalizedString("✔︎ On Top", comment: "✔︎ On Top") : NSLocalizedString("  Not On Top", comment: "  Not On Top"))
    //setWinowsOnTop()
  }
  
  @IBAction func settingBtnPressed(_ sender: AnyObject) {
    let button = sender as! NSButton
    let _ = CGPoint(x: button.frame.origin.x, y: button.frame.origin.y)
    settingMenu.popUp(positioning: nil, at: NSEvent.mouseLocation(), in: nil)
    
  }
  
  // TODO: Rubbish needs to restructure
  @IBOutlet weak var topToggleBtn: NSButton! {
    didSet { self.topToggleBtn.isHidden = true }
  }
  
  @IBAction func toggleAlwaysOnTop(_ sender: AnyObject) {
    
    setWindowsOnTop(isWindowsOnTop() ? .yes : .no)
  }
  
  func updateTime() {
    updateTimer() { (timeString) in
      self.timeLabel.stringValue = timeString
    }
  }
  
  func resumeTimer() {
    
    resumeTimer(self, selector: #selector(updateTime), repeats: true)
  }
  
  func terminateApp() {
    NSApplication.shared().terminate(self)
  }
}

extension LyricsVC {
	
	func showControlPanel() {
		NSAnimationContext.runAnimationGroup({ (context) in
			self.controlPanel.isHidden = true
		}) {
			self.controlPanel.isHidden = false
		}
	}
	
	func hideControlPanel() {
		NSAnimationContext.runAnimationGroup({ (context) in
			self.controlPanel.isHidden = false
		}) {
			self.controlPanel.isHidden = true
		}
	}
	
  @IBAction func dockHide(_ sender: AnyObject) {
    setDocker(.no)
  }
  
  @IBAction func dockUnhide(_ sender: AnyObject) {
    setDocker(.yes)
  }
	
	
	// MARK: NSTrackingAreaOptions
	override func mouseEntered(with theEvent: NSEvent) {
		NSCursor.pointingHand().set()
		view.needsLayout = true
		showControlPanel()
	}
	
	override func mouseExited(with theEvent: NSEvent) {
		NSCursor.arrow().set()
		view.needsLayout = false
		hideControlPanel()
	}

}

extension LyricsVC {
  
  func currentTimeFromString(_ allTimeString: String) -> Int {
    
    let time = Time(allTimeString: allTimeString)
    
		return currentTimeFromInt(time.timeInterval) { (time) in
			
		}
  }
  
	func currentTimeFromInt(_ time: Int, completion:(Int) -> ()) -> Int {
		
		iTunes() { (iTunesApp) in
			
			guard let i = iTunesApp?.spirit(), let iplayerPos = iTunesApp?.spirit().playerPosition, i.running && i.playerState == .playing else {
				
				return completion(time)
			}
			if i.playerState == iTunesEPlS.playing {
				stopTimer()
				initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
				
			} else if i.playerState == iTunesEPlS.paused {
				stopTimer()
			} else if i.playerState == iTunesEPlS.stopped {
				stopTimer()
			} else{
				Debug.print("Lyrics View Controller is not in the case")
			}
			return completion(time - Int(iplayerPos))
		}
	
		spotify() { (spotifyApp) in
			
			guard let s = spotifyApp?.spirit(), let splayerPos = spotifyApp?.spirit().playerPosition, s.running else {
				
				return completion(time)
			}
			stopTimer()
			initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
			
			return completion(time - Int(splayerPos))
		}
		return 0
	}
}

extension LyricsVC {
  
  @IBAction func settingButtonPressed(_ sender: AnyObject) {
    
    let preferenceStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
    let preferenceWC = preferenceStoryboard.instantiateController(withIdentifier: String(describing: PreferencesWC.self)) as! PreferencesWC
    
    preferenceWC.showWindow(self)
  }
  
  @IBAction func quitButtonPressed(_ sender: AnyObject) {
    NSApplication.shared().terminate(self)
  }
}
