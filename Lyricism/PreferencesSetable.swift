//
//  Settings.swift
//  Lyricism
//
//  Created by Stan Liu on 04/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

struct Settings {
  
  static let docker_setting = "show_dock_option"
  static let windows_on_top_setting = "is_always_on_top"
  
  enum Docker: Int {
    case no = 0
    case yes = 1
  }
  
  enum WindowsOnTop: Int {
    case no = 0
    case yes = 1
  }
}

protocol PreferencesSetable { }

extension PreferencesSetable {
  
  func setDocker(type: Settings.Docker) {
    
    switch type {
    case .yes:
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: Settings.docker_setting)
      NSApp.setActivationPolicy(.Regular)
    case .no:
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: Settings.docker_setting)
      NSApp.setActivationPolicy(.Accessory)
    }
  }
  
  func setDocker() {
    
    let option = NSUserDefaults.standardUserDefaults().boolForKey(Settings.docker_setting)
    option ? setDocker(.yes) : setDocker(.no)
  }
  
  func isDockerShown() -> Bool {
    
    return NSUserDefaults.standardUserDefaults().boolForKey(Settings.docker_setting)
  }
  
  func setWindowsOnTop(type: Settings.WindowsOnTop) {
    switch type {
    case .yes:
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: Settings.windows_on_top_setting)
      //print("bool: \(NSUserDefaults.standardUserDefaults().boolForKey(Settings.windows_on_top_setting))")
      
    case .no:
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: Settings.windows_on_top_setting)
      //print("bool: \(NSUserDefaults.standardUserDefaults().boolForKey(Settings.windows_on_top_setting))")
    }
  }
  
  func setWinowsOnTop() {
    
    let option = NSUserDefaults.standardUserDefaults().boolForKey(Settings.windows_on_top_setting)
    option ? setWindowsOnTop(.no) : setWindowsOnTop(.yes)
  }
  
  func isWindowsOnTop() -> Bool {
    
    return NSUserDefaults.standardUserDefaults().boolForKey(Settings.windows_on_top_setting)
  }
}