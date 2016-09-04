//
//  AppearanceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class AppearanceViewController: NSViewController, PreferencesSetable {

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

    override func viewDidLoad() {
        super.viewDidLoad()
      
      isOnDockBtn.state = isDockerShown() ? 1 : 0
      isAlwaysTopBtn.state = isWindowsOnTop() ? 1 : 0
        
    }

    @IBAction func hideDock(sender: AnyObject) {
        
      print("show:\((sender as! NSButton).state)")
      
      setDocker(Settings.Docker(rawValue: isOnDockBtn.state)!)
    }
    
    @IBAction func onTop(sender: AnyObject) {
      
      setWindowsOnTop(Settings.WindowsOnTop(rawValue: isAlwaysTopBtn.state)!)
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