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
import SwiftyUserDefaults

class LyricVC: NSViewController, PlayerGettable, MusicTimerable, DockerSettable, WindowSettable {
	
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
		
		guard let appDelegate = NSApplication.shared().delegate as? AppDelegate, let t = appDelegate.track else {
			return nil
		}
		return t
	}
  
  @IBOutlet weak var isAlwaysOnTop: NSMenuItem!
  @IBOutlet var settingMenu: NSMenu!
  fileprivate var trackingArea: NSTrackingArea!

	fileprivate var preferencesWC: PreferencesWC?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    traigleView = PopoverContentView(frame: view.frame)
    view.addSubview(traigleView!)
    createTrackingArea()
    
    NotificationCenter.default.addObserver(self, selector: #selector(setSourceImage(_:)), name: NSNotification.Name(rawValue: DefaultsKeys.playerSource._key), object: nil)
  }

  override func viewWillAppear() {
    super.viewWillAppear()
   
    showCurrentPlaying()
  }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func showCurrentPlaying() {
		
		guard let source = Defaults[.playerSource] else {
			return
		}
		NotificationCenter.default.post(name: Notification.Name(rawValue: DefaultsKeys.playerSource._key), object: source)
		
		switch source {
		case Identifier.itunes.value():
			
			iTunes() { [unowned self] (iTunesApp) in
				
				Debug.print("itunes is running \(iTunesApp?.unwrap().running)")
				guard let i = iTunesApp, i.unwrap().running && i.unwrap().playerState == .playing else {
					return
				}
				
				let track = EasyTrack(name: i.unwrap().currentTrack!.name!, artist: i.unwrap().currentTrack!.artist!, time: i.unwrap().currentTrack!.time!)
				self.configure(track: track)
				Debug.print("itunes  get current playing information:\(iTunesApp)")
				
			}
		case Identifier.spotify.value():
			
			spotify() { [unowned self] (spotifyApp) in
				
				Debug.print("spotify is running \(spotifyApp?.unwrap().running)")
				guard let s = spotifyApp, s.unwrap().running else {
					return
				}
				guard let track = self.track else {
					return
				}
				
				self.configure(track: track)
				Debug.print("spotify get current playing information:\(spotifyApp)")
			}
		default:
			
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
			Debug.print("error")
		}
	}
	
  // PlayerSourceable Delegate
  func setSourceImage(_ notification: Notification) {
    
    guard let source = notification.object as? Int else {
      
      return
    }
    DispatchQueue.main.async { 
      
      switch source {
      case Identifier.itunes.value(): self.sourceImageView.image = NSImage.iTunes
      case Identifier.spotify.value(): self.sourceImageView.image = NSImage.spotify
      default:
        fatalError("out of SBApplicationID type")
      }
    }
  }
	
	func configure(track: EasyTrack) {
		
		self.trackNameArtistLabel.text = "\(track.artist) - \(track.name)"
		print("time: \(track.time)")
		spinnerProgress.animate = true
		currentTime(time: track.time) { [unowned self] (timeInteger) in
			
			self.trackTime = timeInteger
			guard let realm_track = SFRealm.query(name: track.name, t: Track.self)?.first else {
				Debug.print("realm_track is nil")
				self.searchLyricNArtwork(track)
				return
			}
			
			self.spinnerProgress.animate = false
			
			guard let realm_lyric = realm_track.lyric else {
				Debug.print("lyric is nil")
				self.searchLyricNArtwork(track)
				return
			}
			self.lyric = realm_lyric.text
			
			
			guard let realm_album = realm_track.album, let artwork_data = realm_album.artwork else {
				self.searchLyricNArtwork(track)
				Debug.print("realm_album is nil")
				return
			}
			
			self.imageData = artwork_data as Data
		}
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
      
      DispatchQueue.main.async(execute: { [unowned self] in
				
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
  
  @objc fileprivate func updateTime() {
    updateTimer() { (timeString) in
      self.timeLabel.stringValue = "-" + timeString
    }
  }
  
  func resumeTimer() {
    resumeTimer(self, selector: #selector(updateTime), repeats: true)
  }
  
  fileprivate func terminateApp() {
    NSApplication.shared().terminate(self)
  }
}

extension LyricVC {
	
	func showControlPanel() {
		NSAnimationContext.runAnimationGroup({ [unowned self] (context) in
			self.controlPanel.isHidden = true
		}) {
			self.controlPanel.isHidden = false
		}
	}
	
	func hideControlPanel() {
		NSAnimationContext.runAnimationGroup({ [unowned self] (context) in
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

extension LyricVC {
	
	func currentTime(time: String, completion: (Int) -> Void) {
		
		guard let source = Defaults[.playerSource] else {
			completion(0)
			return
		}
		let timeInteger = Time.integerFrom(string: time)
		
		switch source {
		case Identifier.itunes.value():
			
			iTunes() { (iTunesApp) in
				
				guard let i = iTunesApp?.unwrap(), let playerPos = iTunesApp?.unwrap().playerPosition, i.running && i.playerState == .playing else {
					return completion(timeInteger)
				}
				if i.playerState == iTunesEPlS.playing {
					stopTimer()
					initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
				} else {
					// include iTunesEPlS.paused, iTunesEPlS.stopped
					stopTimer()
					//Debug.print("Lyrics View Controller is not in the case")
				}
				completion(timeInteger - Int(playerPos))
			}
		case Identifier.spotify.value():
			
			spotify() { (spotifyApp) in
				
				guard let s = spotifyApp?.unwrap(), let playerPos = spotifyApp?.unwrap().playerPosition, s.running else {
					return completion(timeInteger)
				}
				stopTimer()
				initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
				
				completion(timeInteger - Int(playerPos))
			}
		default:
			completion(0)
		}
	}
}

extension LyricVC {
  
  @IBAction func settingButtonPressed(_ sender: AnyObject) {
		
		preferencesWC = PreferencesWC.instantiate(withStoryboard: "Preferences")
		preferencesWC?.window?.center()
    preferencesWC?.showWindow(self)
  }
  
  @IBAction func quitButtonPressed(_ sender: AnyObject) {
    NSApplication.shared().terminate(self)
  }
}
