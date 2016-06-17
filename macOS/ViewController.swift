//
//  ViewController.swift
//  macOS
//
//  Created by Stan Liu on 16/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import MediaLibrary
import ScriptingBridge
import WebKit
import Alamofire
import SWXMLHash
import SwiftyJSON

@objc protocol iTunesApplication {
    optional func currentTrack()-> AnyObject
    optional var properties: NSDictionary {get}
    //if you need another object or method from the iTunes.h, you must add it here
}

class WindowController: NSWindowController {
    
    
    override func windowDidLoad() {
        
        
        
    }
}


class ViewController: NSViewController {

    @IBOutlet weak var textView: NSScrollView! {
        
        didSet {
            if let textView = self.textView.contentView.documentView as? NSTextView {
                
                textView.editable = false
                textView.textStorage?.mutableString.setString("default")
            }
        }
    }
    
    var url = NSURL(string: "https://www.google.com/#q=james+blunt+postcards+lyrics")
    
    @IBOutlet weak var webView: WebView! {
        
        didSet {
            
            webView.policyDelegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let request = NSURLRequest(URL: url!)
        webView.mainFrame.loadRequest(request)
        
        NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            // deal with error etc accordingly
            print(data)
            
        }
        */
        /*
        LyricsQueryApi.queryLyrics("", track: "") { (response) in
            
            if response.result.isSuccess {
                
                //textView.textStorage?.mutableString.setString(lyrics as! String)
                
                let json = JSON(data: response.data!)
                print("JSON:\(json)")
            }
        }*/
        
        LyricsQueryApi.getLyrics("adele", track: "hello") { (response) in
            
            
            
        }

        
        if let textView = self.textView.contentView.documentView as? NSTextView {
            
            let iTunesApp: AnyObject = SBApplication(bundleIdentifier: MLMediaSourceiTunesIdentifier)!
            let trackDict = iTunesApp.currentTrack!().properties as Dictionary
            
            
            
            if (trackDict["name"] != nil) {// if nil then no current track
                print(trackDict["name"]!) // print the title
                print(trackDict["artist"]!)
                print(trackDict["album"]!)
                print(trackDict["playedCount"]!)
                // print(trackDict) // print the dictionary
                
                //textView.textStorage?.mutableString.setString(trackDict["name"] as! String)
                
            }
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        
        }
    }
}

extension ViewController: WebPolicyDelegate {
    
    func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        
        if WebNavigationType.LinkClicked.rawValue == actionInformation[WebActionNavigationTypeKey] as! Int {
            listener.ignore()
            //NSWorkspace.sharedWorkspace().openURL(request.URL!)
            webView.mainFrame.loadRequest(request)
        }
        
        print("request url:\(request.URL!)")
        listener.use()
        
    }
    
    func webView(webView: WebView!, decidePolicyForNewWindowAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
        
        
    }
    
    
}

