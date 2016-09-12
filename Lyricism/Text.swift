//
//  Text.swift
//  Lyricism
//
//  Created by Stan Liu on 10/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa


protocol TextViewSetable {
  
  var aligment: NSTextAlignment { get }
  var textColor: NSColor { get }
  
  func fontWithSize(size: CGFloat) -> NSFont
}

extension TextViewSetable {
  
  var aligment: NSTextAlignment { return .Center }
  var textColor: NSColor { return NSColor.whiteColor() }
  
  func fontWithSize(size: CGFloat) -> NSFont {
    
    return NSFont(name: "Lato Regular", size: size)!
  }
}

struct TextViewViewModel { }
extension TextViewViewModel: TextViewSetable { }

extension NSTextField: TextViewSetable { }

extension NSScrollView {
  
  func defaultSetting(withPresenter presenter: TextViewSetable) {
    
    if let textView = self.contentView.documentView as? NSTextView {
      
      textView.font = presenter.fontWithSize(17)
      textView.alignment = presenter.aligment
      textView.textColor = presenter.textColor
    }
  }
}