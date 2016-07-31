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

protocol LyricsViewPresentable {
    
    var lvLyrics: String { get }
    var lvArtworkURL: NSURL? { get }
    var lvTime: String { get }
    var lvArtistNTrack: (artist: String, trackName: String) { get }
}

class LyricsViewController: NSViewController {
    
    @IBOutlet weak var controlPanel: NSView!
    
    var preferenceWindowController: PreferencesWindowController!
    
    private var lyrics: String? {
        didSet {
            guard let textView = self.scrollTextView.contentView.documentView as? NSTextView else {
                
                return
            }
            textView.string = self.lyrics?.applyLyricsFormat() ?? ""
        }
    }
    
    private  var artworkURL: NSURL? {
        didSet {
            self.imageView.image = self.artworkURL != nil ? NSImage(contentsOfURL: self.artworkURL!) : NSImage(named: "avatar")
        }
    }
    var trackTime: Int! = 0
    private var timeString: String = "00:00" {
        
        willSet {
            trackTime = nil
        }
        
        didSet {
            let seconds = String(timeString.characters.dropFirst(2)).copy()
            let minutes = String(timeString.characters.dropLast(3)).stringByReplacingOccurrencesOfString("-", withString: "").copy()
            
            let iTunes = SwiftyiTunes.sharedInstance.iTunes
            trackTime = Int(minutes!.intValue * 60 + seconds!.intValue) - Int(iTunes.playerPosition!)
            
            stopTimer()
            setupTimer(1.0)
        }
    }
    
    private var artistNtrack: (artist: String, trackName: String)? {
        
        didSet {
            if let artistNtrack = artistNtrack {
                self.trackNameArtistLabel.text = "\(artistNtrack.0) - \(artistNtrack.1)"
            } else {
                trackNameArtistLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var timeLabel: NSTextField! {
        didSet { timeLabel.font = NSFont(name: "Lato Regular", size: 25) }
    }
    
    @IBOutlet weak var trackNameArtistLabel: MarqueeView!
    
    var timer: NSTimer?
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var scrollTextView: NSScrollView! {
        didSet {
            if let textView = self.scrollTextView.contentView.documentView as? NSTextView {
                textView.font = NSFont(name: "Lato Regular", size: 17)
                textView.alignment = .Center
                textView.textColor = NSColor.whiteColor()
            }
        }
    }
    
    var traigleView: NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traigleView = PopoverContentView(frame: view.frame)
        view.addSubview(traigleView!)
        createTrackingArea()
        
        if Track.sharedTrack.info.lyric == nil {
            let iTunes = SwiftyiTunes.sharedInstance.iTunes
            guard let artist = iTunes.currentTrack?.artist, name = iTunes.currentTrack?.name, time = iTunes.currentTrack?.time else {
                
                print("iTunes.currentTrack is nil")
                return
            }
            let track = MusiXTrack(artist: artist, name: name, lyrics: nil, time: time, artwork: nil)
            configure(withPresenter: track)
        }
    }
    
    func configure(withPresenter presenter: LyricsViewPresentable) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.lyrics = presenter.lvLyrics
            self.artworkURL = presenter.lvArtworkURL
            self.timeString = presenter.lvTime
            self.artistNtrack = presenter.lvArtistNTrack
        }
        searchLyricNArtwork(presenter)
    }

    
    func searchLyricNArtwork(presenter: LyricsViewPresentable) {
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            MusiXMatchApi.searchLyrics(presenter.lvArtistNTrack.artist, trackName: presenter.lvArtistNTrack.trackName, completion: { (success, lyrics) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.lyrics = lyrics
                    if let urlString = Track.sharedTrack.info.album_coverart_350x350 {
                        self.artworkURL = NSURL(string: urlString)!
                    }
                })
            })
        }
    }
    
    @IBAction func alwaysOnTopBtnPressed(sender: AnyObject) {
        //        isAlwaysOnTop.title = topToggleState ? "✔︎ On Top" : "  Not On Top"
        let attributedString = NSAttributedString(string: !topToggleState ? "✔︎ On Top" : "  Not On Top")
        isAlwaysOnTop.attributedTitle = attributedString
        NSUserDefaults.standardUserDefaults().setBool(!topToggleState, forKey: "isAlwaysOnTop")
    }
    @IBOutlet weak var isAlwaysOnTop: NSMenuItem!
    
    var topToggleState: Bool {
        
        return NSUserDefaults.standardUserDefaults().boolForKey("isAlwaysOnTop")
    }
    @IBOutlet var settingMenu: NSMenu!
    
    private var trackingArea: NSTrackingArea!
    
    func createTrackingArea() {
        
        if trackingArea != nil {
            view.removeTrackingArea(trackingArea)
        }
        let circleRect = view.bounds
        let flag = NSTrackingAreaOptions.MouseEnteredAndExited.rawValue + NSTrackingAreaOptions.ActiveInActiveApp.rawValue
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
        
        NSUserDefaults.standardUserDefaults().setBool(!topToggleState, forKey: "isAlwaysOnTop")
    }
    
    func updateTime() {
        
        if trackTime == 0 {
            stopTimer()
        }
        
        let minutes = trackTime / 60
        let seconds = trackTime % 60
        
        var timeString: String = ""
        
        timeString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        
        timeString = seconds < 10 ? ("\(timeString):0\(seconds)") : ("\(timeString):\(seconds)")

        dispatch_async(dispatch_get_main_queue()) { 
            self.timeLabel.stringValue = timeString
        }
        //print("track time :\(timeString)")
        trackTime = trackTime - 1
    }
    
    func setupTimer(timerInterval: NSTimeInterval) {
        
        timer = NSTimer(timeInterval: timerInterval, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    func resumeTimer() {
        trackTime - 1
        if timer != nil {
            timer = nil
        }
        setupTimer(1.0)
    }
    
    func stopTimer() {
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func terminateApp() {
        
        NSApplication.sharedApplication().terminate(self)
    }
}

extension String {
    
    func applyLyricsFormat() -> String {
        
        
        
        return self == "" ? "Couldn't Find Any Relative Lyrics" : self.stringByReplacingOccurrencesOfString(".", withString: ". \n").stringByReplacingOccurrencesOfString("\n", withString: "\n\n").stringByReplacingOccurrencesOfString("\n ", withString: "\n\n").stringByReplacingOccurrencesOfString(" \n", withString: "\n\n")
    }
}

extension LyricsViewController {
    
    @IBAction func dockHide(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "show_dock_option")
        NSApp.setActivationPolicy(.Accessory)
    }
    
    @IBAction func dockUnhide(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "show_dock_option")
        NSApp.setActivationPolicy(.Regular)
    }
}

extension LyricsViewController {
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


