//
//  FlickrModel.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

public struct FlickrFeed {
    
    let title: String
    let items:[FlickrFeedItem]
}

public struct FlickrFeedItem {
    
    let title: String
    let link: String
    let media: [String:String]
    let dateTaken: String
    let photoDesc: String
    let published: String
    let author: String
    let authorId: String
    let tags: String
    
}

// MARK: - Create from JSON
extension FlickrFeed {
    
    enum JsonKey {
        static let title = "title"
        static let items = "items"
    }
    
    public static func create(fromJson json: [String:Any]) -> FlickrFeed? {
        guard let title = json[JsonKey.title] as? String else {
                return nil
        }
        
        var parsedItems:[FlickrFeedItem] = []
        if let items = json[JsonKey.items] as? [[String:Any]] {
            parsedItems = FlickrFeedItem.create(fromJson: items)
        }
        
        let result = FlickrFeed(title: title, items: parsedItems)
        
        return result
    }
    
    public static func parse(feedAsJsonData jsonData: Data) -> FlickrFeed? {

        
        //
        // Quick&Dirty workaorund here
        //
        // Problem: Flickr feed may return escaped single quote "\'" which is rejected by deserialiser
        //          i.e.  "author": "nobody@flickr.com (\"St. Andrew\'s School (DE)\")"
        //
        // Solution: Replace escaped single quote for unescaped single quote
        //           Data -> String -> replace("\\'" with: "'") -> Data -> JsonObject
        //
        
        guard
            let safeJsonString = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\\'", with: "'"),
            let safeJsonData = safeJsonString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: safeJsonData, options: []),
            let feedAsJsonObject = jsonObject as? Dictionary<String,Any> else {
                return nil
        }

        guard let feed = create(fromJson: feedAsJsonObject) else {
            return nil
        }
        
        return feed
    }
}

extension FlickrFeedItem {
    
    enum JsonKey {
        static let title = "title"
        static let link = "link"
        static let media = "media"
        static let dateTaken = "date_taken"
        static let description = "description"
        static let published = "published"
        static let author = "author"
        static let authorId = "author_id"
        static let tags = "tags"
    }
    
    public static func create(fromJson json: [String:Any?]) -> FlickrFeedItem? {
        
        guard
            let title = json[JsonKey.title] as? String,
            let link = json[JsonKey.link] as? String,
            let media = json[JsonKey.media] as? [String:String],
            let dateTaken = json[JsonKey.dateTaken] as? String,
            let photoDesc = json[JsonKey.description] as? String,
            let published = json[JsonKey.published] as? String,
            let author = json[JsonKey.author] as? String,
            let authorId = json[JsonKey.authorId] as? String,
            let tags = json[JsonKey.tags] as? String
            else {
                return nil
        }
        
        let result = FlickrFeedItem(title: title,
                                    link: link,
                                    media: media,
                                    dateTaken: dateTaken,
                                    photoDesc: photoDesc,
                                    published: published,
                                    author: author,
                                    authorId: authorId,
                                    tags: tags)
        
        return result
    }
    
    public static func create(fromJson json: [[String:Any?]]) -> [FlickrFeedItem] {
        
        let result:[FlickrFeedItem] = json.flatMap { (itemAsJson:[String : Any?]) -> FlickrFeedItem? in
            let item = create(fromJson: itemAsJson)
            return item
        }
        return result
    }
}

