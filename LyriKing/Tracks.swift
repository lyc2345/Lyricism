//
//  Track.swift
//  macOS
//
//  Created by Stan Liu on 17/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation
import SwiftyJSON

class Tracks {

    static let sharedTrack: Tracks = Tracks()
    
    var list: [Track] = []
    
    func addTracks(track: Track) {
        
        list.append(track)
    }
    
    func deleteALL() {
        
        list.removeAll()
        list = []
    }
}
