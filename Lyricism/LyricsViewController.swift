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

class LyricsViewController: NSViewController, MusicTimerable, PreferencesSetable, PlayerSourceable {
  
  var preferenceWindowController: PreferencesWindowController!
  
  private var lyrics: String? {
    
    didSet {
      guard let textView = scrollTextView.contentView.documentView as? NSTextView else { return }
      /*
      let str = self.lyrics?.applyLyricsFormat() ?? ""
      let attrStr =  NSMutableAttributedString(string: str)
      let attributes = [NSForegroundColorAttributeName: NSColor.whiteColor(), NSFontAttributeName: NSFont(name: "Lato Regular", size: 20)!]
      attrStr.setAttributes(attributes, range: NSMakeRange(0, str.characters.count))
      
      textView.textStorage?.setAttributedString(attrStr)
       */
      textView.string = self.lyrics?.applyLyricsFormat() ?? ""
    }
  }
  
  private var imageCache: NSData? {
    
    didSet {
      guard let data = imageCache else {
        return
      }
      imageView.image = NSImage(data: data)
    }
  }
  
  private var artistNtrack: (artist: String, trackName: String)? {
    
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
      textView.alignment = .Center
      textView.textColor = NSColor.whiteColor()
    }
  }
  private var traigleView: NSView?
  // protocol Timerable
  var timer: NSTimer?
  var trackTime: Int!
  
  // This one just for 
  var track: PlayerTrack?
  
  @IBOutlet weak var isAlwaysOnTop: NSMenuItem!
  @IBOutlet var settingMenu: NSMenu!
  private var trackingArea: NSTrackingArea!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    traigleView = PopoverContentView(frame: view.frame)
    view.addSubview(traigleView!)
    createTrackingArea()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setSourceImage(_:)), name: SBApplicationID.sourceKey, object: nil)
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
    
    guard let i = iTunesApp.player where i.running && i.playerState == .Playing else {
      
      guard let s = spotifyApp.player where s.running else {
        
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
      
      NSNotificationCenter.defaultCenter().postNotificationName(SBApplicationID.sourceKey, object: SBApplicationID.spotify.values().player)
      getSpotifyPlayerPlayingInformation(spotifyApp)
      s_print("spotify get current playing information:\(spotifyApp)")
      return
    }
    NSNotificationCenter.defaultCenter().postNotificationName(SBApplicationID.sourceKey, object: SBApplicationID.itunes.values().app)
    getiTunesPlayingInformation(iTunesApp)
    s_print("itunes  get current playing information:\(iTunesApp)")
  }
  
  func getiTunesPlayingInformation<P where P: PlayerPresentable>(p: P) {
    
    guard let artist = p.track_artist, name = p.track_name, time = p.track_time as? String else {
      return
    }
      
    let track = PlayerTrack(artist: artist, name: name, time: time)
    configure(withPresenter: track)
  }
  
  func getSpotifyPlayerPlayingInformation<P where P: PlayerPresentable>(p: P) {
    
    guard let track = track else {
      
      return
    }
    configure(withPresenter: track)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // PlayerSourceable Delegate
  func setSourceImage(notification: NSNotification) {
    
    guard let source = notification.object as? String else {
      
      return
    }
    dispatch_async(dispatch_get_main_queue()) { 
      
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
    
    guard let realm_track = SFRealm.query(name: name!, t: MTrack.self) else {
      s_print("realm_track is nil")
      searchLyricNArtwork(itunes_track)
      return
    }
    
    guard let track_id = (realm_track.valueForKey("lyric_id") as? [Int])?.first else {
      s_print("lyric_id is nil")
      searchLyricNArtwork(itunes_track)
      return
    }
    
    guard let realm_lyric = SFRealm.query(id: track_id, t: MLyric.self), album_id = (realm_track.valueForKey("album_id") as? [Int])?.first else {
      searchLyricNArtwork(itunes_track)
      s_print("realm_lyric or album_id is nil")
      return
    }
    
    lyrics = (realm_lyric.valueForKey("text") as? [String])?.first
    
    guard let realm_album = SFRealm.query(id: album_id, t: MAlbum.self), artwork_data = (realm_album.valueForKey("artwork") as? [NSData])?.first else {
      searchLyricNArtwork(itunes_track)
      s_print("realm_album is nil")
      return
    }
    imageCache = artwork_data
    
    guard let track_time = (realm_track.valueForKey("time") as? [Int])?.first else {
      
      trackTime = currentTimeFromString(time)
      return
    }
    trackTime = currentTimeFromInt(track_time)
    spinnerProgress.animate = false
  }
  
  func searchLyricNArtwork(presenter: LyricsViewPresentable) {
    
    MusiXMatchApi.searchLyrics(presenter.lvArtistNTrack.artist, trackName: presenter.lvArtistNTrack.trackName, completion: { (success, info, lyric) in
      
      dispatch_async(dispatch_get_main_queue(), {
        self.spinnerProgress.animate = false
      })
      
      guard let i = info, ly = lyric else {
        self.s_print("info , lyric is nil")
        return
      }
      
      guard let urlString = i.album_coverart_350x350, url = NSURL(string:urlString) else {
        self.s_print("urlString, url is nil")
        return
      }
      
      dispatch_async(dispatch_get_main_queue(), {
        
        self.lyrics = ly.text
        self.imageCache = NSData(contentsOfURL: url)
        
        self.spinnerProgress.animate = false
      })
      
      let t = MTrack()
      t.id = i.track_id.integerValue
      t.name = i.track_name
      t.time = Time(allTimeString: presenter.lvTime).timeInterval
      t.album_name = i.album_name
      t.lyric_id = i.lyrics_id.integerValue
      t.album_id = i.album_id.integerValue
      t.spotify_id = i.track_spotify_id.integerValue
      t.artist_id = i.artist_id.integerValue
      SFRealm.update(t)
      
      let a = MAlbum()
      a.id = i.album_id.integerValue
      a.name = i.album_name
      a.artist_id = i.artist_id.integerValue
      a.url_str = i.album_coverart_350x350!
      
      a.artwork = NSData(contentsOfURL: url)
      a.tracks.value = i.track_id.integerValue
      SFRealm.update(a)
      
      let art = MArtist()
      art.id = i.artist_id.integerValue
      art.name = i.artist_name
      SFRealm.update(art)
      
      let l = MLyric()
      l.id = i.lyrics_id.integerValue
      l.name = i.track_name
      l.text = ly.text
      SFRealm.update(l)
    })
  }
  
  func createTrackingArea() {
    
    if trackingArea != nil {
      view.removeTrackingArea(trackingArea)
    }
    let circleRect = view.bounds
    //let flag = NSTrackingAreaOptions.MouseEnteredAndExited.rawValue + NSTrackingAreaOptions.ActiveInKeyWindow.rawValue
    let flag = NSTrackingAreaOptions.MouseEnteredAndExited.rawValue + NSTrackingAreaOptions.ActiveAlways.rawValue
    trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
    view.addTrackingArea(trackingArea)
    hideControlPanel()
  }
  
  // MARK: NSTrackingAreaOptions
  override func mouseEntered(theEvent: NSEvent) {
    NSCursor.pointingHandCursor().set()
    view.needsLayout = true
    showControlPanel()
  }
  
  override func mouseExited(theEvent: NSEvent) {
    NSCursor.arrowCursor().set()
    view.needsLayout = false
    hideControlPanel()
  }
  
  func showControlPanel() {
    NSAnimationContext.runAnimationGroup({ (context) in
      self.controlPanel.hidden = true
    }) {
      self.controlPanel.hidden = false
    }
  }
  
  func hideControlPanel() {
    NSAnimationContext.runAnimationGroup({ (context) in
      self.controlPanel.hidden = false
    }) {
      self.controlPanel.hidden = true
    }
  }
  
  @IBAction func alwaysOnTopBtnPressed(sender: AnyObject) {
    
    isAlwaysOnTop.attributedTitle = NSAttributedString(string: !isWindowsOnTop() ? NSLocalizedString("✔︎ On Top", comment: "✔︎ On Top") : NSLocalizedString("  Not On Top", comment: "  Not On Top"))
    //setWinowsOnTop()
  }
  
  @IBAction func settingBtnPressed(sender: AnyObject) {
    let button = sender as! NSButton
    let _ = CGPoint(x: button.frame.origin.x, y: button.frame.origin.y)
    settingMenu.popUpMenuPositioningItem(nil, atLocation: NSEvent.mouseLocation(), inView: nil)
    
  }
  
  // TODO: Rubbish needs to restructure
  @IBOutlet weak var topToggleBtn: NSButton! {
    didSet { self.topToggleBtn.hidden = true }
  }
  
  @IBAction func toggleAlwaysOnTop(sender: AnyObject) {
    
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
    NSApplication.sharedApplication().terminate(self)
  }
}

extension String {
  
  func applyLyricsFormat() -> String {
    
    return self == "" ? NSLocalizedString("Couldn't Find Any Relative Lyrics", comment: "Couldn't Find Any Relative Lyrics") : self.stringByReplacingOccurrencesOfString(".", withString: ". \n").stringByReplacingOccurrencesOfString("  ", withString: "\n")
  }
}

extension LyricsViewController {
  
  @IBAction func dockHide(sender: AnyObject) {
    setDocker(.no)
  }
  
  @IBAction func dockUnhide(sender: AnyObject) {
    setDocker(.yes)
  }
}

extension LyricsViewController {
  
  struct Time {
    
    let allTimeString: String
    var timeInterval: Int = 0
    
    init(allTimeString: String) {
      
      self.allTimeString = allTimeString
      
      let s = String(allTimeString.characters.dropFirst(2)).copy() as! NSString
      let m = String(allTimeString.characters.dropLast(3)).stringByReplacingOccurrencesOfString("-", withString: "").copy() as! NSString
      
      timeInterval = Int(m.intValue * 60 + s.intValue) - Int(0)
    }
  }
  
  func currentTimeFromString(allTimeString: String) -> Int {
    
    let time = Time(allTimeString: allTimeString)
    
    return currentTimeFromInt(time.timeInterval)
  }
  
  func currentTimeFromInt(time: Int) -> Int {
    
    let iTunesApp = iTunes(player: SBApplication(bundleIdentifier: SBApplicationID.itunes.values().app))
    
    guard let i = iTunesApp.player, iplayerPos = iTunesApp.player?.playerPosition where i.running && i.playerState == .Playing else {
      
      let spotifyApp = Spotify(player: SBApplication(bundleIdentifier: SBApplicationID.spotify.values().app))
      
      guard let s = spotifyApp.player, splayerPos = spotifyApp.player?.playerPosition where s.running else {
        
        return time - Int(0)
      }
      
      stopTimer()
      initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
      
      return time - Int(splayerPos)
    }
    
    if i.playerState == iTunesEPlS.Playing {
      stopTimer()
      initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
      
    } else if i.playerState == iTunesEPlS.Paused {
      stopTimer()
    } else if i.playerState == iTunesEPlS.Stopped {
      stopTimer()
    } else{
      s_print("Lyrics View Controller is not in the case")
    }
    return time - Int(iplayerPos)
  }
  
  /*
   override func mouseDragged(theEvent: NSEvent) {
   let currentLocation = NSEvent.mouseLocation()
   print("dragged at:\(currentLocation)")
   
   var newOrigin = currentLocation
   let screenFrame = NSScreen.mainScreen()?.frame
   let windowFrame = view.window?.frame
   
   if let screen = screenFrame {
   newOrigin.x = screen.size.width - currentLocation.x
   newOrigin.y = screen.size.width - currentLocation.y
   
   print("the New Origin points:\(newOrigin)")
   
   if newOrigin.x < 450 {
   newOrigin.x = 450
   }
   
   if newOrigin.y < 650 {
   newOrigin.y = 650
   
   }
   print("the New Origin points:\(newOrigin)")
   
   let appDelegate: AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
   appDelegate.popover.contentSize = NSSize(width: newOrigin.x, height: newOrigin.y)
   }
   }*/
}

extension LyricsViewController {
  
  @IBAction func settingButtonPressed(sender: AnyObject) {
    
    let preferenceStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
    preferenceWindowController = preferenceStoryboard.instantiateControllerWithIdentifier(String(PreferencesWindowController)) as! PreferencesWindowController
    
    preferenceWindowController.showWindow(self)
  }
  
  @IBAction func quitButtonPressed(sender: AnyObject) {
    NSApplication.sharedApplication().terminate(self)
  }
}

extension LyricsViewController: NSTextDelegate {
  
  func textDidChange(notification: NSNotification) {
    
    
  }
}
