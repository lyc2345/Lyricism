//
//  SFRealm.swift
//  Lyricism
//
//  Created by Stan Liu on 10/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import RealmSwift

class SFRealm {
  
  class func write<T>(_ t: T) where T: Object {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(t)
      }
    } catch let error as NSError {
      
      Debug.print("SFRealm write error:\(error.localizedDescription)")
    }
  }
	
	class func update(saveHandler: @escaping () -> Void) {
		
		do {
			let realm = try Realm()
			try realm.write() {
				saveHandler()
				
			}
		} catch let error as NSError {
			
			Debug.print("SFRealm update error:\(error.localizedDescription)")
		}
	}
	
  class func update<T>(_ t: T) where T: Object {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(t, update: true)
      }
    } catch let error as NSError {
      
      Debug.print("SFRealm update error:\(error.localizedDescription)")
    }
  }
  
  class func create<T>(predicate p: [String: AnyObject], t: T.Type) where T: Object {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.create(t.self, value: p, update: true)
      }
    } catch let error as NSError {
      
      Debug.print("SFRealm update error:\(error.localizedDescription)")
    }
  }
  
  class func delete<T>(_ t: T) where T: Object {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.delete(t)
      }
    } catch let error as NSError {
      
      Debug.print("SFRealm delete error:\(error.localizedDescription)")
    }
  }
  
  class func queryAll<T>(_ t: T.Type) -> Results<T>? where T: Object {
    
    let realm = try! Realm()
    
    return realm.objects(t.self)
  }
  
  class func query<T>(id i: Int, t: T.Type) -> Results<T>? where T: Object {
    
    let realm = try! Realm()
    
    return realm.objects(t.self).filter("id == \(i)")
  }
  
  class func query<T>(name n: String, t: T.Type) -> Results<T>? where T: Object {
    
    let realm = try! Realm()
    
    let predicate = NSPredicate(format: "name = %@", n)
    
    return realm.objects(t.self).filter(predicate)

  }
  
  class func query<T>(predict p: String, t: T.Type) -> Results<T>? where T: Object {
    
    let realm = try! Realm()
    
    return realm.objects(t.self).filter(p)
  }

}
