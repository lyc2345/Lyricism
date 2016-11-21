//
//  MResponse.swift
//  LyriKing
//
//  Created by Stan Liu on 27/06/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import Foundation

public struct MResponse {
    
    public let lyrics: String?
    public let photo100x100URL: URL?
    public let photo350x350URL: URL?
    public let photo500x500URL: URL?
    public let photo600x600URL: URL?
    public let trackID: NSNumber?
    public let albumName: String?
    public let albumID: NSNumber?
    
    public init(
        lyrics: String?,
        photo100x100URL: URL?,
        photo350x350URL: URL?,
        photo500x500URL: URL?,
        photo600x600URL: URL?,
        trackID: NSNumber?,
        albumName: String?,
        albumID: NSNumber?) {
        
        self.lyrics = lyrics
        self.photo100x100URL = photo100x100URL
        self.photo350x350URL = photo350x350URL
        self.photo500x500URL = photo500x500URL
        self.photo600x600URL = photo600x600URL
        self.trackID = trackID
        self.albumName = albumName
        self.albumID = albumID
        
    }
}
