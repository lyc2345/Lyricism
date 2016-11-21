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
  
  func setDocker(_ type: Settings.Docker) {
    
    switch type {
    case .yes:
      UserDefaults.standard.set(true, forKey: Settings.docker_setting)
      NSApp.setActivationPolicy(.regular)
    case .no:
      UserDefaults.standard.set(false, forKey: Settings.docker_setting)
      NSApp.setActivationPolicy(.accessory)
    }
  }
  
  func setDocker() {
    
    let option = UserDefaults.standard.bool(forKey: Settings.docker_setting)
    option ? setDocker(.yes) : setDocker(.no)
  }
  
  func isDockerShown() -> Bool {
    
    return UserDefaults.standard.bool(forKey: Settings.docker_setting)
  }
  
  func setWindowsOnTop(_ type: Settings.WindowsOnTop) {
    switch type {
    case .yes:
      UserDefaults.standard.set(true, forKey: Settings.windows_on_top_setting)
      //print("bool: \(NSUserDefaults.standardUserDefaults().boolForKey(Settings.windows_on_top_setting))")
      
    case .no:
      UserDefaults.standard.set(false, forKey: Settings.windows_on_top_setting)
      //print("bool: \(NSUserDefaults.standardUserDefaults().boolForKey(Settings.windows_on_top_setting))")
    }
  }
  
  func setWinowsOnTop() {
    
    let option = UserDefaults.standard.bool(forKey: Settings.windows_on_top_setting)
    option ? setWindowsOnTop(.no) : setWindowsOnTop(.yes)
  }
  
  func isWindowsOnTop() -> Bool {
    
    return UserDefaults.standard.bool(forKey: Settings.windows_on_top_setting)
  }
}
