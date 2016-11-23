//
//  Timerable.swift
//
//
//  Created by Stan Liu on 02/09/2016.
//
//

import Cocoa

protocol MusicTimerable {
  
  var timer: Timer? { get set }
  var trackTime: Int! { get set }
  
  func initTimer(_ timeInterval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool)
  
  func resumeTimer(_ target: AnyObject, selector: Selector, repeats: Bool)
  func stopTimer()
}

extension MusicTimerable where Self: LyricVC {
  
  func initTimer(_ timeInterval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool) {
    
    timer =  Timer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: repeats)
    
    RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
  }
  
  func updateTimer(_ handler: @escaping (_ timeString: String) -> Void) {
    
    if trackTime == 0 {
      self.stopTimer()
    }
    
    trackTime = trackTime - 1
    
    let minutes = trackTime / 60
    let seconds = trackTime % 60
    
    var timeString: String = ""
    
    timeString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
    
    timeString = seconds < 10 ? ("\(timeString):0\(seconds)") : ("\(timeString):\(seconds)")
    
    DispatchQueue.main.async {
      //self.timeLabel.stringValue = timeString
      handler(timeString)
    }
    //s_print("track time :\(timeString)")
  }
  
  func resumeTimer(_ target: AnyObject, selector: Selector, repeats: Bool) {
    
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
    timer!.invalidate()
    timer = nil
  }
}

