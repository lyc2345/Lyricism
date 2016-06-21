//
//  ITunesSearchApi.swift
//  ITunesSwift
//
//  Created by Kazuyoshi Tsuchiya on 2014/09/21.
//  Copyright (c) 2014 tsuchikazu. All rights reserved.
//

import Foundation
import Alamofire

public class ITunesSearchApi {
    let url = "https://itunes.apple.com/search"
    
    var term: String?
    var media: Media?
    var entity: Entity?
    var attribute: Attribute?
    var limit: Int?
    var explicit: String?
    
    var country: String?
    var lang: String?
    var version: Int?
    
    
    public init(media: Media) {
        self.media = media
    }
    
    public init(entity: Entity) {
        self.entity = entity
    }
    
    
    public func by(term: String) -> ITunesSearchApi {
        self.term = term
        return self
    }
    
    public func by(attribute: Attribute, term: String) -> ITunesSearchApi {
        self.attribute = attribute
        self.term = term
        return self
    }
    
    public func limit(limit: Int) -> ITunesSearchApi {
        self.limit = limit
        return self
    }
    
    public func explicit(explicit: Bool) -> ITunesSearchApi {
        if explicit {
            self.explicit = "Yes"
        } else {
            self.explicit = "No"
        }
        return self
    }
    
    public func at(country: String) -> ITunesSearchApi {
        self.country = country
        return self
    }
    
    public func `in`(lang: String) -> ITunesSearchApi {
        self.lang = lang
        return self
    }
    
    public func use(version: Int) -> ITunesSearchApi {
        self.version = version
        return self
    }
    
    
    public func request(completionHandler: (Response<String, NSError>) -> Void) -> Void {
        Alamofire.request(.GET, self.buildUrl()).responseString { (response) in
            completionHandler(response)
        }
    }
    
    internal func buildUrl() -> String {
        var params: [String] = []
        
        if let term: String = self.term {
            params.append("term=" + term)
        }
        if let media = self.media {
            params.append("media=" + media.rawValue)
        }
        if let entity = self.entity {
            params.append("entity=" + entity.rawValue)
        }
        if let attribute = self.attribute {
            params.append("attribute=" + attribute.rawValue)
        }
        if let limit = self.limit {
            params.append("limit=" + String(limit))
        }
        if let explicit = self.explicit {
            params.append("explicit=" + explicit)
        }
        if let country = self.country {
            params.append("country=" + country)
        }
        if let lang = self.lang {
            params.append("lang=" + lang)
        }
        if let version = self.version {
            params.append("version=" + String(version))
        }
        
        var queryString: String = "?"
        for param: String in params {
            queryString += param + "&"
        }
        
        return self.url + queryString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
}
