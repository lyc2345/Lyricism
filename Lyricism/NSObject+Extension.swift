//
//  NSObject+Extension.swift
//  macOS
//
//  Created by Stan Liu on 18/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation

class iOSXFoundation {
    
    class func getClassPropertyNames(_ myClass: AnyClass) -> [String] {
        
        var results: [String] = []
        var count: UInt32 = 0
        let properties = class_copyPropertyList(myClass, &count)
        
        for i: UInt32 in 0 ..< count {
            
            let property = properties?[Int(i)]
            let cname = property_getName(property)
            let name = String(cString: cname!)
            results.append(name)
        }
        free(properties)
        
        return results
    }
    
    
    class func propertyValues(_ classObject: AnyClass) {
        
        //let myClass: AnyClass = classObject.classForCoder
        
        let propertyNames: [String] = getClassPropertyNames(classObject)
        var count: UInt32 = 0
        let properties = class_copyPropertyList(classObject, &count)
        
        //weak var player: Player? = Player.sharedPlayer
        
        for name in propertyNames {
            
            //let cname = name.cStringUsingEncoding(NSUTF8StringEncoding)
//            if let value = player!.value(forKey: name) {
//                
//                //print("property name: \(name), value:\(value)")
//            }
        }
    }
    
}

extension NSObject {
    
    func propertyNames() -> [String] {
        
        var results: [String] = []
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0
        let myClass: AnyClass = self.classForCoder
        let properties = class_copyPropertyList(myClass, &count)
        
        // iterate each objc_property_t struct
        for i: UInt32 in 0 ..< count {
            
            let property = properties?[Int(i)]
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property)
            // convert the c string into a swift string
            let name = String(cString: cname!)
            results.append(name)
        }
        
        // release objc_property_t struct
        free(properties)
        
        return results
    }
    
    func propertyValues(_ myClass: NSObject) {
        
        let propertiesName: [String] = myClass.propertyNames()
        
        
        for (_, name) in propertiesName.enumerated() {
            
            //s_print("property name: \(name), value:\(myClass.valueForKey(name))")
        }
    }
    
    func attributes() -> [AnyObject] {
        
        var results: [AnyObject] = []
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0
        let myClass: AnyClass = self.classForCoder
        let properties = class_copyPropertyList(myClass, &count)
        
        // iterate each objc_property_t struct
        for i: UInt32 in 0 ..< count {
            
            let property = properties?[Int(i)]
            
            let attribute = property_getAttributes(property)
            let attributeString = String(validatingUTF8: attribute!)
            //s_print("attributeString:\(attributeString!)")
            let attributes = attributeString!.components(separatedBy: ",")
            
            results.append(attributes as AnyObject)
        }
        
        // release objc_property_t struct
        free(properties)
        
        return results
    }
}
