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

// Change Triagle Background Color
class PopoverContentView: NSView {
    
    var backgroundView: PopoverBackgroundView?
    override func viewDidMoveToWindow() {
        
        super.viewDidMoveToWindow()
        
        if let frameView = self.window?.contentView?.superview {
            if backgroundView == nil {
                
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable, .ViewHeightSizable]);
                frameView.addSubview(backgroundView!, positioned: NSWindowOrderingMode.Below, relativeTo: frameView)
            }
        }
    }
}
// Change Triagle Background Color
class PopoverBackgroundView: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 0.4).set()
        NSRectFill(bounds)
    }
}

class LyricsViewController: NSViewController {
    
    @IBOutlet weak var bottomPanel: NSView!
    @IBOutlet weak var bottomPanelHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var controlPanel: NSView!
    
    var lyrics: String? {
        didSet {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let textView = self.scrollTextView.contentView.documentView as? NSTextView where self.lyrics != nil {
                    textView.string = self.lyrics?.applyLyricsFormat()
                    return
                }
                if let textView = self.scrollTextView.contentView.documentView as? NSTextView {
                    textView.string = ""
                }
            })
        }
    }
    var artworkURL: NSURL? {
        
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                
                self.imageView.image = self.artworkURL != nil ? NSImage(contentsOfURL: self.artworkURL!) : NSImage(named: "avatar")
            })
        }
    }
    var trackTime: Int! = 0
    var timeString: String = "00:00" {
        
        willSet {
            trackTime = nil
            print("time string will set")
        }
        
        didSet {
            print("time string did set")
            let seconds = String(timeString.characters.dropFirst(2)).copy()
            let minutes = String(timeString.characters.dropLast(3)).stringByReplacingOccurrencesOfString("-", withString: "").copy()
            printLog("timestring:\(timeString)")
            printLog("second:\(String(timeString.characters.dropFirst(3))), minutes:\(String(timeString.characters.dropLast(3)).stringByReplacingOccurrencesOfString("-", withString: ""))")
            
            let iTunes = SwiftyiTunes.sharedInstance.iTunes
            trackTime = Int(minutes!.intValue * 60 + seconds!.intValue) - Int(iTunes.playerPosition!)
            
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            setupTimer(1.0)
        }
    }
    
    var marqueeText: String? {
        
        didSet {
            if let marqueeText = marqueeText where marqueeText != " - " {
                self.trackNameArtistLabel.text = marqueeText
            } else {
                trackNameArtistLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var timeLabel: NSTextField!
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
    
    var topToggleState: Bool = true {
        
        didSet {
            topToggleBtn.image = (topToggleState ? NSImage(named: "pin") : NSImage(named: "unpin"))
        }
    }
    
    private var trackingArea: NSTrackingArea!
    func createTrackingArea() {
        if trackingArea != nil {
            
            view.removeTrackingArea(trackingArea)
        }
        let circleRect = view.bounds
        let flag = NSTrackingAreaOptions.MouseEnteredAndExited.rawValue + NSTrackingAreaOptions.ActiveInActiveApp.rawValue
        trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        NSCursor.pointingHandCursor().set()
        view.needsLayout = true
        print("mouse go innnnnnnn")
        //showControlPanel()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        NSCursor.arrowCursor().set()
        view.needsLayout = false
        print("mouse go outtttttt")
        //hideControlPanel()
    }
    
    func showControlPanel() {
        NSAnimationContext.runAnimationGroup({ (context) in
            //
            self.bottomPanelHeight.constant = 0
            
        }) {
            //
            self.bottomPanelHeight.constant = 50
        }
    }
    
    func hideControlPanel() {
        NSAnimationContext.runAnimationGroup({ (context) in
            //
            self.bottomPanelHeight.constant = 50
            
        }) {
            //
            self.bottomPanelHeight.constant = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        traigleView = PopoverContentView(frame: view.frame)
        view.addSubview(traigleView!)
     
        
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        createTrackingArea()
        let iTunes = SwiftyiTunes.sharedInstance.iTunes
        guard let artist = iTunes.currentTrack?.artist, track = iTunes.currentTrack?.name else {
            return
        }
        marqueeText = "\(artist) - \(track)"
    }
    
    deinit {
        
    }
    
    
    @IBOutlet weak var topToggleBtn: NSButton! {
        
        didSet {
            topToggleBtn.image = (topToggleState ? NSImage(named: "pin") : NSImage(named: "unpin"))
        }
    }
    
    @IBAction func toggleAlwaysOnTop(sender: AnyObject) {
        
        topToggleState = !topToggleState
    }

    
    func updateTime() {
        
        if trackTime == 0 {
            stopTimer()
        }
        
        let minutes = trackTime / 60
        let seconds = trackTime % 60
        
        var timeString: String = ""
        if minutes < 10 {
            timeString = "0\(minutes)"
        } else {
            timeString = "\(minutes)"
        }
        if seconds < 10 {
            timeString = ("\(timeString):0\(seconds)")
        } else {
            timeString = ("\(timeString):\(seconds)")
        }
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
        
        return self.stringByReplacingOccurrencesOfString(".", withString: ". \n").stringByReplacingOccurrencesOfString("\n", withString: "\n\n").stringByReplacingOccurrencesOfString("\n ", withString: "\n\n").stringByReplacingOccurrencesOfString(" \n", withString: "\n\n")
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