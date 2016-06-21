//
//  LyricsViewController.swift
//  macOS
//
//  Created by Stan Liu on 17/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import SwiftyJSON
import ScriptingBridge
import AVFoundation

class PopoverContentView: NSView {
    
    var backgroundView:PopoverBackgroundView?
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

class PopoverBackgroundView: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor(colorLiteralRed: 41.0/255.0, green: 48.0/255.0, blue: 66.0/255.0, alpha: 0.4).set()
        NSRectFill(bounds)
    }
}

class LyricsViewController: NSViewController {
    
    var lyrics: String? {
        
        didSet {
            if let textView = self.scrollTextView.contentView.documentView as? NSTextView {
                textView.string = lyrics?.applyLyricsFormat()
            }
        }
    }
    var coverImageURL: NSURL? {
        
        didSet {
            
            if let imageURL = coverImageURL, let imageView = self.imageView {
                
                imageView.image = NSImage(contentsOfURL: imageURL)
            }
        }
    }
    var timeString: String = "00:00" {
        
        didSet {
            let seconds = String(timeString.characters.dropFirst(3))
            let minutes = String(timeString.characters.dropLast(3)).stringByReplacingOccurrencesOfString("-", withString: "")
            
            trackTime = Int64(NSString(string: minutes).integerValue * 60 + NSString(string: seconds).integerValue)
            
            if timer != nil {
                
                timer!.invalidate()
                timer = nil
            }
            
            timer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
        }
    }
    
    @IBOutlet weak var timeLabel: NSTextField!
    
    var timer: NSTimer?
    var trackTime: Int64!
    
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var scrollTextView: NSScrollView!
    
    var traigleView: NSView?
    
    var topToggleState: Bool = true {
        
        didSet {
            topToggleBtn.image = (topToggleState ? NSImage(named: "pin") : NSImage(named: "unpin"))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        traigleView = PopoverContentView(frame: view.frame)
        view.addSubview(traigleView!)
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
            timer!.invalidate()
            timer = nil
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
        
        return self.stringByReplacingOccurrencesOfString(".", withString: ". \n").stringByReplacingOccurrencesOfString("\n", withString: "\n\n").stringByReplacingOccurrencesOfString("\n\n\n", withString: "\n\n")
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