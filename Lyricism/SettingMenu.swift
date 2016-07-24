//
//  SettingMenu.swift
//  LyriKing
//
//  Created by Stan Liu on 02/07/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class SettingMenu: NSMenu {

    override init(title aTitle: String) {
        
        super.init(title: aTitle)
        createMenu()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(title: "Setting Page")
        createMenu()
    }
    
    func createMenu() {
        
        self.addItem(NSMenuItem(title: "Setting", action: #selector(toggleSetting), keyEquivalent: "S"))
        self.addItem(NSMenuItem.separatorItem())
        self.addItem(NSMenuItem(title: "Quit", action: #selector(toggleQuit), keyEquivalent: "q"))
    }
    
    func toggleSetting() {
        
    }
    
    func toggleQuit() {
        
        NSApplication.sharedApplication().terminate(self)
    }
}
