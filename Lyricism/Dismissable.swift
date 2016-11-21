//
//  Dismissable.swift
//  Lyricism
//
//  Created by Stan Liu on 21/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation

protocol Dismissable {
	
	var dismissTimer: Timer! { get set }
	var dismissTime: Int { get set }
}

extension Dismissable where Self: AppDelegate {
	
	func timerStop() {
		if let timer = dismissTimer {
			timer.invalidate()
			dismissTimer = nil
			dismissTime = 4
		}
	}
	
	func timerStart() {
		
		guard let timer = dismissTimer else {
			dismissTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(dismissTimerCountDown), userInfo: nil, repeats: true)
			return
		}
		timer.invalidate()
		dismissTimer = nil
	}
}

