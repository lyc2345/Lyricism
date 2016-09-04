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

class ViewController: NSViewController {
  
  @IBOutlet weak var scrollTextView: NSScrollView! {
    
    didSet {
      if let textView = self.scrollTextView.contentView.documentView as? NSTextView {
        
        textView.editable = false
        textView.textStorage?.mutableString.setString("default")
      }
    }
  }
  @IBOutlet weak var imageView: NSImageView!
  
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
     
     }*/
  }
  
  override var representedObject: AnyObject? {
    didSet {
      // Update the view, if already loaded.
      
    }
  }
  
  deinit {
    
  }
  
  func printAllTheLibraryName() {
    
    
  }
  
  func getCurrentIconImage() {
    
    
    iOSXFoundation.propertyValues(Track)
    
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

