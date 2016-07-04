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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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