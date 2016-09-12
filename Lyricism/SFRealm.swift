//
//  SFRealm.swift
//  Lyricism
//
//  Created by Stan Liu on 10/09/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Cocoa
import RealmSwift

enum TString: String {
  
  case album = "album_id"
  case artist = "artist_id"
  case track = "track_id"
  case lyric = "lyric_id"
}

class SFRealm {
  
  class func write<T where T: Object>(t: T) {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(t)
      }
    } catch let error as NSError {
      
      print("SFRealm write error:\(error.localizedDescription)")
    }
  }
  
  class func update<T where T: Object>(t: T) {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(t, update: true)
      }
    } catch let error as NSError {
      
      print("SFRealm update error:\(error.localizedDescription)")
    }
  }
  
  class func create<T where T: Object>(predicate p: [String: AnyObject], t: T.Type) {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.create(t.self, value: p, update: true)
      }
    } catch let error as NSError {
      
      print("SFRealm update error:\(error.localizedDescription)")
    }
  }
  
  class func delete<T where T: Object>(t: T) {
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.delete(t)
      }
    } catch let error as NSError {
      
      print("SFRealm delete error:\(error.localizedDescription)")
    }
  }
  
  class func queryAll<T where T: Object>(t: T.Type) -> Results<T>? {
    
    let realm = try! Realm()
    
    return realm.objects(t.self)
  }
  
  class func query<T where T: Object>(id i: Int, t: T.Type) -> Results<T>? {
    
    let realm = try! Realm()
    
    return realm.objects(t.self).filter("id == \(i)")
  }
  
  class func query<T where T: Object>(name n: String, t: T.Type) -> Results<T>? {
    
    let realm = try! Realm()
    
    let predicate = NSPredicate(format: "name = %@", n)
    
    return realm.objects(t.self).filter(predicate)

  }
  
  class func query<T where T: Object>(predict p: String, t: T.Type) -> Results<T>? {
    
    let realm = try! Realm()
    
    return realm.objects(t.self).filter(p)
  }

}