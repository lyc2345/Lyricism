//
//  Settings.swift
//  Lyricism
//
//  Created by Stan Liu on 04/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

struct Settings {
  
  enum Docker: Int {
    case no = 0
    case yes = 1
  }
  
  enum WindowsOnTop: Int {
    case no = 0
    case yes = 1
  }
}

protocol DockerSettable { }

extension DockerSettable {
  
  func setDocker(_ type: Settings.Docker) {
    
    switch type {
    case .yes:
			
			Defaults[.isDockShow] = true
			
      NSApp.setActivationPolicy(.regular)
    case .no:
      Defaults[.isDockShow] = false
      NSApp.setActivationPolicy(.accessory)
    }
  }
  
  func setDocker() {
    
    let option = Defaults[.isDockShow]
    option ? setDocker(.yes) : setDocker(.no)
  }
  
  func isDockerShown() -> Bool {
		
		return Defaults[.isDockShow]
  }
}

protocol WindowSettable { }

extension WindowSettable {
	
	func setWindowsOnTop(_ type: Settings.WindowsOnTop) {
		switch type {
		case .yes:
			Defaults[.isAlwaysTop] = true
			
		case .no:
			Defaults[.isAlwaysTop] = false
		}
	}
	
	func setWinowsOnTop() {
		
		let option = Defaults[.isAlwaysTop]
		option ? setWindowsOnTop(.no) : setWindowsOnTop(.yes)
	}
	
	func isWindowsOnTop() -> Bool {
		
		return Defaults[.isAlwaysTop]
	}
}
