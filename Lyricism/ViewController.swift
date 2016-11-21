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
import SwiftyJSON

class ViewController: NSViewController {
  
  @IBOutlet weak var scrollTextView: NSScrollView! {
    
    didSet {
      if let textView = self.scrollTextView.contentView.documentView as? NSTextView {
        
        textView.isEditable = false
        textView.textStorage?.mutableString.setString("default")
      }
    }
  }
  @IBOutlet weak var imageView: NSImageView!
  
  @IBOutlet weak var webView: WebView! {
    didSet { webView.policyDelegate = self }
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
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
      
    }
  }
  
  
}

extension ViewController: WebPolicyDelegate {
  
  func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable: Any]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
    
    if WebNavigationType.linkClicked.rawValue == actionInformation[WebActionNavigationTypeKey] as! Int {
      listener.ignore()
      //NSWorkspace.sharedWorkspace().openURL(request.URL!)
      webView.mainFrame.load(request)
    }
    
    print("request url:\(request.url!)")
    listener.use()
    
  }
  
  func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable: Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
    
  }
}

