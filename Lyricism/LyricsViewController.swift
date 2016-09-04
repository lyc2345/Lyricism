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

protocol TextViewSetable {
    
    var aligment: NSTextAlignment { get }
    var textColor: NSColor { get }
    
    func fontWithSize(size: CGFloat) -> NSFont
}

extension TextViewSetable {
    
    var aligment: NSTextAlignment { return .Center }
    var textColor: NSColor { return NSColor.whiteColor() }
    
    func fontWithSize(size: CGFloat) -> NSFont {
        
        return NSFont(name: "Lato Regular", size: size)!
    }
}

struct TextViewViewModel { }
extension TextViewViewModel: TextViewSetable { }

extension NSTextField: TextViewSetable { }

extension NSScrollView {
    
    func defaultSetting(withPresenter presenter: TextViewSetable) {
        
        if let textView = self.contentView.documentView as? NSTextView {
            
            textView.font = presenter.fontWithSize(17)
            textView.alignment = presenter.aligment
            textView.textColor = presenter.textColor
        }
    }
}

class LyricsViewController: NSViewController, MusicTimerable, PreferencesSetable {
    
    @IBOutlet weak var controlPanel: NSView!
    
    var preferenceWindowController: PreferencesWindowController!
    
    private var lyrics: String? {
        didSet {
            guard let textView = scrollTextView.contentView.documentView as? NSTextView else {
                
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
    // protocol Timerable
    var timer: NSTimer?
    var trackTime: Int!
    
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
            //setupTimer(1.0)
            initTimer(1.0, target: self, selector: #selector(updateTime), repeats: true)
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
        didSet { timeLabel.font = timeLabel.fontWithSize(25) }
    }
    
    @IBOutlet weak var trackNameArtistLabel: MarqueeView!
    
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var scrollTextView: NSScrollView! {
        didSet { self.scrollTextView.defaultSetting(withPresenter: TextViewViewModel()) }
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
        
        isAlwaysOnTop.attributedTitle = NSAttributedString(string: !isWindowsOnTop() ? "✔︎ On Top" : "  Not On Top")
        setWinowsOnTop()
    }
    @IBOutlet weak var isAlwaysOnTop: NSMenuItem!

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
        
        return self == "" ? "Couldn't Find Any Relative Lyrics" : self.stringByReplacingOccurrencesOfString(".", withString: ". \n").stringByReplacingOccurrencesOfString("\n", withString: "\n\n").stringByReplacingOccurrencesOfString("\n ", withString: "\n\n").stringByReplacingOccurrencesOfString(" \n", withString: "\n\n")
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


