//
//  Timerable.swift
//
//
//  Created by Stan Liu on 02/09/2016.
//
//

import Cocoa

protocol MusicTimerable {
  
  var timer: NSTimer? { get set }
  var trackTime: Int! { get set }
  
  func initTimer(timeInterval: NSTimeInterval, target: AnyObject, selector: Selector, repeats: Bool)
  
  func resumeTimer(target: AnyObject, selector: Selector, repeats: Bool)
  func stopTimer()
}

extension MusicTimerable where Self: LyricsViewController {
  
  func initTimer(timeInterval: NSTimeInterval, target: AnyObject, selector: Selector, repeats: Bool) {
    
    timer =  NSTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: repeats)
    
    NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
  }
  
  func updateTimer(handler: (timeString: String) -> Void) {
    
    if trackTime == 0 {
      self.stopTimer()
    }
    
    let minutes = trackTime / 60
    let seconds = trackTime % 60
    
    var timeString: String = ""
    
    timeString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
    
    timeString = seconds < 10 ? ("\(timeString):0\(seconds)") : ("\(timeString):\(seconds)")
    
    dispatch_async(dispatch_get_main_queue()) {
      //self.timeLabel.stringValue = timeString
      handler(timeString: timeString)
    }
    //print("track time :\(timeString)")
    trackTime = trackTime - 1
    
  }
  
  func resumeTimer(target: AnyObject, selector: Selector, repeats: Bool) {
    
    trackTime - 1
    
    if timer != nil {
      timer!.invalidate()
      timer = nil
    }
    initTimer(1.0, target: target, selector: selector, repeats: repeats)
  }
  
  func stopTimer() {
    
    guard timer != nil else {
      
      return
    }
    timer?.invalidate()
    timer = nil
  }
}

protocol DismissTimerable {
  
  var dismissTimer: NSTimer! { get set }
  var dismissTime: Int { get set }
}

extension DismissTimerable where Self: AppDelegate {
  
  func timerStop() {
    if let timer = dismissTimer {
      timer.invalidate()
      dismissTimer = nil
      dismissTime = 4
    }
  }
  
  func timerStart() {
    
    guard let timer = dismissTimer else {
      dismissTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(dismissTimerCountDown), userInfo: nil, repeats: true)
      return
    }
    timer.invalidate()
    dismissTimer = nil
  }
  
}

