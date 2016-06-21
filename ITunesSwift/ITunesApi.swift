//
//  ITunesApi.swift
//  ITunesSwift
//
//  Created by Kazuyoshi Tsuchiya on 2014/09/23.
//  Copyright (c) 2014 tsuchikazu. All rights reserved.
//

public class ITunesApi {
    class public func findAll() -> ITunesSearchApi {
        return ITunesSearchApi(media: Media.All)
    }
    class public func find(media: Media) -> ITunesSearchApi {
        return ITunesSearchApi(media: media)
    }
    class public func find(entity: Entity) -> ITunesSearchApi {
        return ITunesSearchApi(entity: entity)
    }
    class public func lookup(id: Int) -> ITunesLookupApi {
        return ITunesLookupApi(idName: "id", id: id)
    }
    class public func lookup(idName: String, id: Int) -> ITunesLookupApi {
        return ITunesLookupApi(idName: idName, id: id)
    }
}

public typealias iTunesApi = ITunesApi