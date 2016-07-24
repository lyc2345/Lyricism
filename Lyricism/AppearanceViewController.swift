//
//  AppearanceViewController.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class AppearanceViewController: NSViewController {

    /*
    @IBOutlet weak var scrollView: NSScrollView! {
        didSet {
            if let tableView = scrollView.documentView as? NSTableView {
                tableView.setDataSource(self)
                tableView.setDelegate(self)
                print("delegate yo ho")
                tableView.backgroundColor = NSColor.grayColor()
            }
        }
    }*/
    @IBOutlet weak var isOnDockBtn: NSButton!
    @IBOutlet weak var isAlwaysTopBtn: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isOnDockBtn.state = NSUserDefaults.standardUserDefaults().boolForKey("show_dock_option") ? 1: 0
        isAlwaysTopBtn.state = NSUserDefaults.standardUserDefaults().boolForKey("isAlwaysOnTop") ? 1: 0
    }

    @IBAction func hideDock(sender: AnyObject) {
        
        print("show:\((sender as! NSButton).state)")
        
        if isOnDockBtn.state == 1 {
        
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "show_dock_option")
            NSApp.setActivationPolicy(.Regular)
            
        } else {
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "show_dock_option")
            NSApp.setActivationPolicy(.Accessory)
        }
    }
    
    @IBAction func onTop(sender: AnyObject) {
        
        if isAlwaysTopBtn.state == 1 {
        
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isAlwaysOnTop")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isAlwaysOnTop")
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