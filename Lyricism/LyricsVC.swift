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

protocol LyricsViewPresentable {
  
  var lvTime: String { get }
  var lvArtistNTrack: (artist: String, trackName: String) { get }
  var lvTrack: PlayerTrack { get }
}

class LyricsVC: NSViewController, MusicTimerable, PreferencesSetable, PlayerSourceable {
  
  var preferenceWC: PreferencesWC!
  
  fileprivate var lyric: Lyric? {
    
    didSet {
      guard let textView = scrollTextView.contentView.documentView as? NSTextView else { return }
      /*
      let str = self.lyrics?.applyLyricsFormat() ?? ""
      let attrStr =  NSMutableAttributedString(string: str)
      let attributes = [NSForegroundColorAttributeName: NSColor.whiteColor(), NSFontAttributeName: NSFont(name: "Lato Regular", size: 20)!]
      attrStr.setAttributes(attributes, range: NSMakeRange(0, str.characters.count))
      
      textView.textStorage?.setAttributedString(attrStr)
       */
      textView.string = self.lyric?.text.applyLyricsFormat() ?? ""
    }
  }
  
  fileprivate var imageData: Data? {
    
    didSet {
      guard let data = imageData else {
        return
      }
      imageView.image = NSImage(data: data)
    }
  }
  
  fileprivate var artistNtrack: (artist: String, trackName: String)? {
    
    didSet {
      guard let artistNtrack = artistNtrack else {
        
        trackNameArtistLabel.text = ""
        return
      }
      self.trackNameArtistLabel.text = "\(artistNtrack.0) - \(artistNtrack.1)"
    }
  }
  
  @IBOutlet weak var spinnerProgress: Spinner!
  @IBOutlet weak var controlPanel: NSView!
  @IBOutlet weak var sourceImageView: NSImageView! { didSet { sourceImageView.alphaValue = 0.4 } }
  @IBOutlet weak var timeLabel: NSTextField! { didSet { timeLabel.font = NSFont(name: "Lato Regular", size: 25)! } }
  @IBOutlet weak var trackNameArtistLabel: MarqueeView!
  @IBOutlet weak var imageView: NSImageView!
  @IBOutlet weak var scrollTextView: NSScrollView! {
    didSet {
      guard let textView = self.scrollTextView.contentView.documentView as? NSTextView  else {
        return
      }
      textView.font = NSFont(name: "Lato Regular", size: 20)!
      textView.alignment = .center
      textView.textColor = NSColor.white
    }
  }
  fileprivate var traigleView: NSView?
  // protocol Timerable
  var timer: Timer?
  var trackTime: Int!
  
  // This one just for 
  var track: PlayerTrack?
  
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
  
  func showCurrentPlaying() {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    s_print("itunes is running \(iTunesApp.player?.running)")
    let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
    s_print("spotify is running \(spotifyApp.player?.running)")
    
    guard let i = iTunesApp.player, i.running && i.playerState == .playing else {
      
      guard let s = spotifyApp.player, s.running else {
        
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
      
      NotificationCenter.default.post(name: Notification.Name(rawValue: SBApplicationID.sourceKey), object: SBApplicationID.spotify.values().player)
      getSpotifyPlayerPlayingInformation(spotifyApp)
      s_print("spotify get current playing information:\(spotifyApp)")
      return
    }
    NotificationCenter.default.post(name: Notification.Name(rawValue: SBApplicationID.sourceKey), object: SBApplicationID.itunes.values().app)
    getiTunesPlayingInformation(iTunesApp)
    s_print("itunes  get current playing information:\(iTunesApp)")
  }
  
  func getiTunesPlayingInformation<P>(_ p: P) where P: PlayerPresentable {
    
    guard let artist = p.track_artist, let name = p.track_name, let time = p.track_time as? String else {
      return
    }
      
    let track = PlayerTrack(artist: artist, name: name, time: time)
    configure(withPresenter: track)
  }
  
  func getSpotifyPlayerPlayingInformation<P>(_ p: P) where P: PlayerPresentable {
    
    guard let track = track else {
      
      return
    }
    configure(withPresenter: track)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // PlayerSourceable Delegate
  func setSourceImage(_ notification: Notification) {
    
    guard let source = notification.object as? String else {
      
      return
    }
    DispatchQueue.main.async { 
      
      switch source {
      case SBApplicationID.itunes.values().app: self.sourceImageView.image = NSImage(named: "iTunes")
      case SBApplicationID.spotify.values().app: self.sourceImageView.image = NSImage(named: "spotify")
      default:
        fatalError("out of SBApplicationID type")
      }
    }
  }
  
  func beforeConfigure(withPresenter presenter: LyricsViewPresentable) {
    
    artistNtrack = presenter.lvArtistNTrack
  }
  
  func configure(withPresenter presenter: LyricsViewPresentable) {
    print("time: \(presenter.lvTime)")
    spinnerProgress.animate = true
    trackTime = currentTimeFromString(presenter.lvTime)
    artistNtrack = presenter.lvArtistNTrack
    track = presenter.lvTrack
    
    let artist = artistNtrack?.artist
    let name = artistNtrack?.trackName
    let time = presenter.lvTime

    let itunes_track = PlayerTrack(artist: artist!, name: name!, time: time)
    
    guard let realm_track = SFRealm.query(name: name!, t: Track.self) else {
      s_print("realm_track is nil")
      searchLyricNArtwork(itunes_track)
      return
    }
    
    guard let track_id = (realm_track.value(forKey: "lyric_id") as? [Int])?.first else {
      s_print("lyric_id is nil")
      searchLyricNArtwork(itunes_track)
      return
    }
    
    guard let realm_lyric = SFRealm.query(id: track_id, t: Lyric.self), let album_id = (realm_track.value(forKey: "album_id") as? [Int])?.first else {
      searchLyricNArtwork(itunes_track)
      s_print("realm_lyric or album_id is nil")
      return
    }
    
    lyric = realm_lyric.first
    
    guard let realm_album = SFRealm.query(id: album_id, t: Album.self), let artwork_data = (realm_album.value(forKey: "artwork") as? [NSData])?.first else {
      searchLyricNArtwork(itunes_track)
      s_print("realm_album is nil")
      return
    }
    imageData = artwork_data as Data
    
    guard let track_time = (realm_track.value(forKey: "time") as? [Int])?.first else {
      
      trackTime = currentTimeFromString(time)
      return
    }
    trackTime = currentTimeFromInt(track_time)
    spinnerProgress.animate = false
  }
  
  func searchLyricNArtwork(_ presenter: LyricsViewPresentable) {
    
    MusiXMatchApi.searchLyrics(presenter.lvArtistNTrack.artist, trackName: presenter.lvArtistNTrack.trackName, completion: { (success, info, lyric) in
      
      DispatchQueue.main.async(execute: {
        self.spinnerProgress.animate = false
      })
			
			guard success == true else {
				self.s_print("request is failured!")
				return
			}
      
      guard let i = info, let ly = lyric else {
        self.s_print("info , lyric is nil")
        return
      }
      
      guard let urlString = i.album_coverart_350x350, let url = URL(string:urlString) else {
        self.s_print("urlString, url is nil")
        return
      }
      
      DispatchQueue.main.async(execute: {
        
        self.lyric = Lyric()
        self.imageData = try? Data(contentsOf: url)
      })
		})
  }
  
  func createTrackingArea() {
    
    if trackingArea != nil {
      view.removeTrackingArea(trackingArea)
    }
    let circleRect = view.bounds
    //let flag = NSTrackingAreaOptions.MouseEnteredAndExited.rawValue + NSTrackingAreaOptions.ActiveInKeyWindow.rawValue
    let flag = NSTrackingAreaOptions.mouseEnteredAndExited.rawValue + NSTrackingAreaOptions.activeAlways.rawValue
    trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
    view.addTrackingArea(trackingArea)
    hideControlPanel()
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

extension String {
  
  func applyLyricsFormat() -> String {
    
    return self == "" ? NSLocalizedString("Couldn't Find Any Relative Lyrics", comment: "Couldn't Find Any Relative Lyrics") : self.replacingOccurrences(of: ".", with: ". \n").replacingOccurrences(of: "  ", with: "\n")
  }
}

extension LyricsVC {
  
  @IBAction func dockHide(_ sender: AnyObject) {
    setDocker(.no)
  }
  
  @IBAction func dockUnhide(_ sender: AnyObject) {
    setDocker(.yes)
  }
}

extension LyricsVC {
  
  func currentTimeFromString(_ allTimeString: String) -> Int {
    
    let time = Time(allTimeString: allTimeString)
    
    return currentTimeFromInt(time.timeInterval)
  }
  
  func currentTimeFromInt(_ time: Int) -> Int {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    guard let i = iTunesApp.player, let iplayerPos = iTunesApp.player?.playerPosition, i.running && i.playerState == .playing else {
      
      let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
      
      guard let s = spotifyApp.player, let splayerPos = spotifyApp.player?.playerPosition, s.running else {
        
        return time - Int(0)
      }
      
      stopTimer()
      initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
      
      return time - Int(splayerPos)
    }
    
    if i.playerState == iTunesEPlS.playing {
      stopTimer()
      initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
      
    } else if i.playerState == iTunesEPlS.paused {
      stopTimer()
    } else if i.playerState == iTunesEPlS.stopped {
      stopTimer()
    } else{
      s_print("Lyrics View Controller is not in the case")
    }
    return time - Int(iplayerPos)
  }
}

extension LyricsVC {
  
  @IBAction func settingButtonPressed(_ sender: AnyObject) {
    
    let preferenceStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
    preferenceWC = preferenceStoryboard.instantiateController(withIdentifier: String(describing: PreferencesWC.self)) as! PreferencesWC
    
    preferenceWC.showWindow(self)
  }
  
  @IBAction func quitButtonPressed(_ sender: AnyObject) {
    NSApplication.shared().terminate(self)
  }
}

extension LyricsVC: NSTextDelegate {
  
  func textDidChange(_ notification: Notification) {
    
    
  }
}
