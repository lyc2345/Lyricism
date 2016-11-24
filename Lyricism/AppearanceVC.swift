//
//  AppearanceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import ScriptingBridge
import SwiftyUserDefaults

class AppearanceVC: NSViewController, DockerSettable, WindowSettable, PlayerSourceable {

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
			
			switch getPlayerSource() {
			case .itunes(nil):
				iTunesButton.selected(true)
			case .spotify(nil):
				spotifyButton.selected(true)
			default:
				iTunesButton.selected(true)
				Debug.print("get source error")
			}
    }

    @IBAction func hideDock(_ sender: AnyObject) {
        
      Debug.print("show:\((sender as! NSButton).state)")
      
      setDocker(Settings.Docker(rawValue: isOnDockBtn.state)!)
    }
    
    @IBAction func onTop(_ sender: AnyObject) {
      
      setWindowsOnTop(Settings.WindowsOnTop(rawValue: isAlwaysTopBtn.state)!)
    }
  
  func clean() {
    
    for button in sourceButtons {
      
      button.selected(false)
    }
  }
  
  @IBAction func sourceButtonsPressed(_ sender: AnyObject) {
    
    clean()
    
    (sender as! NSButton).selected(true)
    
    setPlayerSource((sender as! NSButton) == iTunesButton ? .itunes("") : .spotify(""))
    Debug.print("source: \((sender as! NSButton) == iTunesButton ? "itunes" : "spotify")")
	
    NotificationCenter.default.post(name: Notification.Name(rawValue: DefaultsKeys.playerSource._key), object: nil)
  }
  
  func setSourceImage(_ type: App<SBApplication>) { }
}

extension NSButton {
  
  func selected(_ option: Bool) {
    
    // This must set, otherwise it won't appear layer
    self.wantsLayer = true
    
    if option {
      self.layer?.borderWidth = 5.0
      self.layer?.borderColor = NSColor.white.cgColor
      self.layer?.cornerRadius = self.frame.height / 2
      self.layer?.masksToBounds = true
    } else {
      self.layer?.borderColor = NSColor.clear.cgColor
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
