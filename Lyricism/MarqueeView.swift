//
//  MarqueeTextField.swift
//  LyriKing
//
//  Created by Stan Liu on 27/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa

class MarqueeView: NSView {

    var timer: NSTimer? = nil
    
    var fullString: String? = ""
    var point: CGPoint! = CGPointZero
    var stringWidth: CGFloat!
    
    var textAttributes: [String: AnyObject] = [NSFontAttributeName: NSFont(name: "Lato Light", size: 23.0)!, NSForegroundColorAttributeName: NSColor.whiteColor()]
    // yellow color for test marquee label
    var otherTextAttributes: [String: AnyObject] = [NSFontAttributeName: NSFont(name: "Lato Light", size: 23.0)!, NSForegroundColorAttributeName: NSColor.yellowColor()]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    deinit {
        
        timer?.invalidate()
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        stringWidth = NSString(string: text).sizeWithAttributes(textAttributes).width
        // if title width smaller than self.frame. make title in the center
        if stringWidth < self.frame.width {
            timer?.invalidate()
            timer = nil
            let centerPointX = CGPoint(x: (self.frame.width - stringWidth) / 2, y: point.y)
            NSString(string: text).drawAtPoint(centerPointX, withAttributes: textAttributes)
            return
        }
        

        // Drawing code here.
        //self.printLog("point.x: \(point.x)")
        if point.x < -stringWidth {
            
            point.x += stringWidth  + 20
        }
        NSString(string: text).drawAtPoint(point, withAttributes: textAttributes)
        
        if point.x + stringWidth > 0 {
            var otherPoint = point
            //otherPoint.x += dirtyRect.size.width
            otherPoint.x += stringWidth + 20
            NSString(string: text).drawAtPoint(otherPoint, withAttributes: textAttributes)
        }
    }
    
    var text: String = "" {
        
        didSet {
            //self.printLog("label.stringvalue: \(text)")
            fullString = text.copy() as? String
            point = NSZeroPoint
            stringWidth = NSString(string: text).sizeWithAttributes(textAttributes).width
            
            if timer == nil && speed > 0 && fullString != nil {
                
                timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: #selector(moveText), userInfo: nil, repeats: true)
            }
        }
    }
    /*
    func setText(newText: String) {
        
        fullString = newText.copy() as? String
        point = NSZeroPoint
        stringWidth = NSString(string: newText).sizeWithAttributes(textAttributes).width
        
        if timer == nil && speed > 0 && fullString != nil {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: #selector(moveText), userInfo: nil, repeats: true)
        }
    }*/
    
    func moveText(t: NSTimer) {
        
        dispatch_async(dispatch_get_main_queue()) { 
            //self.printLog("maqueree moveText")
            self.point.x = self.point.x - 1.0
            self.needsDisplay = true
        }
    }
    
    var speed: NSTimeInterval = 0.02 {
        
        didSet {
            
            timer?.invalidate()
            timer = nil
            if speed > 0 && fullString != nil {
                timer = NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: #selector(moveText), userInfo: nil, repeats: true)
            }
        }
    }
    /*
    func setSpeed(newSpeed: NSTimeInterval) {
        
        if newSpeed != speed {
            
            speed = newSpeed
            timer?.invalidate()
            timer = nil
            
            timer = NSTimer(timeInterval: 0.2, target: self, selector: #selector(moveText), userInfo: nil, repeats: true)
        }
    }
    */
}


extension String {
    
    func copy() -> AnyObject? {
        
        if let asCopying = (self as AnyObject) as? NSCopying {
            return asCopying.copyWithZone(nil)
        } else {
            assert(false, "This class doesn't implement NSCopying")
            return nil
        }
    }
}
