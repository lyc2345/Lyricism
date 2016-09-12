//
//  AppearanceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

protocol PlayerSourceable {
  
  func setPlayerSource(type: SBApplicationID)
  func getPlayerSource() -> SBApplicationID
}

extension PlayerSourceable where Self: NSViewController {
  
  func setPlayerSource(type: SBApplicationID) {
    
    switch type {
    case .itunes: NSUserDefaults.standardUserDefaults().setInteger(0, forKey: SBApplicationID.sourceKey)
    case .spotify:
      NSUserDefaults.standardUserDefaults().setInteger(1, forKey: SBApplicationID.sourceKey)
    }
  }
  
  func getPlayerSource() -> SBApplicationID {
    
    switch NSUserDefaults.standardUserDefaults().integerForKey(SBApplicationID.sourceKey) {
    case 0: return SBApplicationID.itunes
    case 1: return SBApplicationID.spotify
    default:
      print("getPlayerSource SBApplicationID out of bounds, AppearanceViewController, Line: 33")
      return SBApplicationID.itunes
    }
  }
}

class AppearanceViewController: NSViewController, PreferencesSetable, PlayerSourceable {

    /*
    @IBOutlet weak var scrollView: NSScrollView! {
        didSet {
            if let tableView = scrollView.documentView as? NSTableView {
                tableView.setDataSource(self)
                tableView.setDelegate(self)
                tableView.backgroundColor = NSColor.grayColor()
            }
        }
    }*/
    @IBOutlet weak var isOnDockBtn: NSButton!
    @IBOutlet weak var isAlwaysTopBtn: NSButton!
  
  var sourceButtons: [NSButton]!
  
  @IBOutlet weak var iTunesButton: NSButton!
  
  @IBOutlet weak var spotifyButton: NSButton!
  
  var delegate: PlayerSourceable?

    override func viewDidLoad() {
        super.viewDidLoad()
      
      isOnDockBtn.state = isDockerShown() ? 1 : 0
      isAlwaysTopBtn.state = isWindowsOnTop() ? 1 : 0
      
      sourceButtons = [iTunesButton, spotifyButton]
      
      clean()
      getPlayerSource() == .itunes ? iTunesButton.selected(true) : spotifyButton.selected(true)
    }

    @IBAction func hideDock(sender: AnyObject) {
        
      print("show:\((sender as! NSButton).state)")
      
      setDocker(Settings.Docker(rawValue: isOnDockBtn.state)!)
    }
    
    @IBAction func onTop(sender: AnyObject) {
      
      setWindowsOnTop(Settings.WindowsOnTop(rawValue: isAlwaysTopBtn.state)!)
    }
  
  func clean() {
    
    for button in sourceButtons {
      
      button.selected(false)
    }
  }
  
  @IBAction func sourceButtonsPressed(sender: AnyObject) {
    
    clean()
    
    (sender as! NSButton).selected(true)
    
    setPlayerSource((sender as! NSButton) == iTunesButton ? .itunes : .spotify)
    print("source: \((sender as! NSButton) == iTunesButton ? "itunes" : "spotify")")
    
    NSNotificationCenter.defaultCenter().postNotificationName(SBApplicationID.sourceKey, object: nil)
  }
  
  func setSourceImage(type: SBApplicationID) { }
}

extension NSButton {
  
  func selected(option: Bool) {
    
    // This must set, otherwise it won't appear layer
    self.wantsLayer = true
    
    if option {
      self.layer?.borderWidth = 5.0
      self.layer?.borderColor = NSColor.whiteColor().CGColor
      self.layer?.cornerRadius = self.frame.height / 2
      self.layer?.masksToBounds = true
    } else {
      self.layer?.borderColor = NSColor.clearColor().CGColor
    }
  }
}

/*
extension AppearanceViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let text = "I am a text"
        var cellIdentifier = "cell"
        
        
        if tableColumn == tableView.tableColumns[0] {
            
            cellIdentifier = "cell"
        }
        
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        return nil
    }
}

extension AppearanceViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 1
    }
    
    
}
 */