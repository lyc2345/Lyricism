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

class LyricsViewController: NSViewController {
    
    @IBOutlet weak var imageView: NSImageView!  {
        
        didSet {
            //imageView.imageScaling = .ScaleNone
            //imageView.imageAlignment = .AlignCenter
        }
    }
    @IBOutlet weak var scrollTextView: NSScrollView! {
        
        didSet {
            
            if let textView = scrollTextView.contentView.documentView as? NSTextView {
                
                //
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(songSwitch), name: "com.apple.iTunes.playerInfo", object: nil)
        
        let track = Track.sharedTrack
        
        guard let imageURLString = track.album_coverart_350x350 else {
            
            return
        }
        
        if let imageURL = NSURL(string: imageURLString), let image = NSImage(contentsOfURL: imageURL) {
            self.imageView.image = image
        }
    }
    
    deinit {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func songSwitch(notification: NSNotification) {
        
        let trackDict = MacUtilities.getCurrentMusicInfo()
        guard let artist = trackDict?.artist,
            track = trackDict?.track else {
                return
        }
        
        MusiXMatchApi.getLyrics(artist, track: track) { (response) in
            
            let trackJSON = JSON(data: response.data!)
            //print("track json: \(trackJSON)")
            
            if let lyrics = trackJSON["message"]["body"]["lyrics"]["lyrics_body"].string {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    
                    
                    if let textView = self.scrollTextView.contentView.documentView as? NSTextView {
                        textView.textStorage?.mutableString.setString(lyrics)
                        
                        let track = Track.sharedTrack
                        
                        if let imageURL = NSURL(string: track.album_coverart_100x100), let image = NSImage(contentsOfURL: imageURL) {
                            self.imageView.image = image
                        }
                    }
                })
            }
        }
    }
    
    func terminateApp() {
        
        NSApplication.sharedApplication().terminate(self)
    }
}

extension LyricsViewController {
    
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
        
        
    }
}