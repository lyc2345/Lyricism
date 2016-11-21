//
//  NSFont+Gotcha.swift
//  gotchamap
//
//  Created by Jesselin on 2016/7/22.
//  Copyright © 2016年 JesseLin. All rights reserved.
//

import Cocoa

extension NSFont {
    
    fileprivate enum FontFamily {
        static let Regular = "Lato Regular"
        static let Bold = "Lato Bold"
        static let Light = "Lato Light"
    }
    
    // MARK: - Private Methods
    
    fileprivate class func appRegularFontOfSize(_ fontSize: CGFloat) -> NSFont {
        return NSFont(name: FontFamily.Regular, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
    }
    
    fileprivate class func appBoldFontOfSize(_ fontSize: CGFloat) -> NSFont {
        return NSFont(name: FontFamily.Bold, size: fontSize) ?? NSFont.boldSystemFont(ofSize: fontSize)
    }
    
    // MARK: - Public Methods
    
    class func fontForLyricDisplay() -> NSFont {
        return NSFont.appRegularFontOfSize(20)
    }
    
    class func fontForTimer() -> NSFont {
        return NSFont.appRegularFontOfSize(25)
    }
    
    class func fontForMarqueeLabel() -> NSFont {
        return NSFont.appRegularFontOfSize(23)
    }
	
	class func fontForPopover() -> NSFont {
		return NSFont.appRegularFontOfSize(12)
	}
}


