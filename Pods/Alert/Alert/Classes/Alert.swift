//
//  AlertPresentable.swift
//  AlertPresentable
//
//  Created by Stan Liu on 17/10/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit

public struct Alert {
  
  /// create a UIAlertController
  public static func with(title t: String, message: String, style: UIAlertControllerStyle, completion: (() -> Void)? = nil) -> UIAlertController {
    
    presentCompletion = completion
    return UIAlertController(title: t, message: message, preferredStyle: style)
  }
}

var presentCompletion: (() -> Void)?

public protocol AlertCreatable {
  
  func alert(with title: String, message: String, style: UIAlertControllerStyle, completion: (() -> Void)?) -> UIAlertController
}

public protocol AlertPresentable {
  
  // to present alert controller
  func show(_ completion: (() -> Void)?)
}

public protocol AlertActionBindable {
  
  // add a button to a alert controller with properties and handler
  func bind(button title: String, style: UIAlertActionStyle, completion: ((UIAlertAction) -> Void)?) -> UIAlertController
  
  /// add a button to a alert controller with UIAlertController func
  func bind(action a: UIAlertAction) -> UIAlertController
}

public protocol AlertTextFieldBindable {
  
  /// add a textfield to a alert controller with properties and handler
  func bind(textfield text: String?, placeholder: String, secure: Bool, returnHandler: @escaping (UITextField) -> Void) -> UIAlertController
}


extension AlertCreatable where Self: NSObject {
  
  public func alert(with title: String, message: String, style: UIAlertControllerStyle, completion: (() -> Void)? = nil) -> UIAlertController {
    presentCompletion = completion
    return UIAlertController(title: title, message: message, preferredStyle: style)
  }
}

public extension AlertPresentable where Self: UIAlertController {
  
  func show(_ completion: (() -> Void)? = nil) {
    
    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
      
      print("Something wrong with your rootViewController at: \(#file), func: \(#function), line: \(#line)")
      return
    }
    rootViewController.present(self, animated: true, completion: completion ?? presentCompletion)
  }
}

public extension AlertActionBindable where Self: UIAlertController {
  
  func bind(button title: String, style: UIAlertActionStyle = .default, completion: ((UIAlertAction) -> Void)?) -> UIAlertController {
    
    let alertAction = UIAlertAction(title: title, style: style, handler: completion)
    addAction(alertAction)
    
    return self
  }
  
  func bind(action a: UIAlertAction) -> UIAlertController {
    
    addAction(a)
    return self
  }
}

public extension AlertTextFieldBindable where Self: UIAlertController {
  
  func bind(textfield text: String? = nil, placeholder: String, secure: Bool = false, returnHandler: @escaping (UITextField) -> Void) -> UIAlertController {
    
    addTextField { (customTextField) in
      
      customTextField.text = text
      customTextField.placeholder = placeholder
      customTextField.isSecureTextEntry = secure
      customTextField.addTarget(self, action: #selector(self.textFieldDidBeginEdit), for: .editingChanged)
      returnHandler(customTextField)
    }
    return self
  }
}

public extension UIAlertController {
  
  func textFieldDidBeginEdit() {
    
    let topViewController = UIApplication.shared.windows.first?.rootViewController
    
    if topViewController?.presentedViewController != nil {
      
      if let topViewController = topViewController?.presentedViewController, topViewController is UIAlertController {
        
        let usernameTextfield = (topViewController as! UIAlertController).textFields?.first
        let passwordTextfield = (topViewController as! UIAlertController).textFields?.last
        let confirmAction = (topViewController as! UIAlertController).actions.first
        
        confirmAction?.isEnabled = (((usernameTextfield?.text?.characters.count)! > 0) && ((passwordTextfield?.text?.characters.count)! > 0))
      }
    }
  }
}


extension UIAlertController: AlertPresentable { }
extension UIAlertController: AlertActionBindable { }
extension UIAlertController: AlertTextFieldBindable { }
