//
//  FlickrModelTests.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import XCTest
@testable import FlickrBrowser
import RxSwift
import RxCocoa

class FlickrFeedTests: XCTestCase {

    private let createMockFlickrFeed = { (mockTitle: String, items:[[String: Any]]) -> [String: Any] in
        
        let result:[String: Any] = ["title":mockTitle,
                                     "items": items]
        return result
        
    }
    
    private let createMockFlickrFeedItem = { (prefix: String) -> [String: Any] in
        
        let result:[String: Any] = [
                "title": "\(prefix)_DSC_7702",
                "link": "\(prefix)_https://www.flickr.com/photos/saltspringsailing/34193341504/",
                "media": [
                    "m": "\(prefix)_https://farm5.staticflickr.com/4195/34193341504_739834c596_m.jpg"
                ],
                "date_taken": "\(prefix)_2017-05-20T11:31:06-08:00",
                "description": "\(prefix)_Lore Ipsum",
                "published": "\(prefix)_2017-06-01T19:15:37Z",
                "author": "\(prefix)_nobody@flickr.com",
                "author_id": "\(prefix)_51694109@N03",
                "tags": "\(prefix)_ tag1 tag2"
        ]
        
        return result
        
    }
    
    // MARK: -
    func testCreateFlickrFeed_NoItems() {
        
        // prepare
        let feedAsJson = createMockFlickrFeed("feed_1", [])
        
        // execute
        let result = FlickrFeed.create(fromJson: feedAsJson)
        
        // verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "feed_1")
        XCTAssertEqual(result?.items.count, 0)
    }
    
    func testCreateFlickrFeed_OneItem() {
        
        // prepare
        let feedAsJson = createMockFlickrFeed("feed_1", [createMockFlickrFeedItem("#1")])
        
        // execute
        let result = FlickrFeed.create(fromJson: feedAsJson)
        
        // verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "feed_1")
        XCTAssertEqual(result?.items.count, 1)
        let item = result!.items[0]
        XCTAssertEqual(item.title, "#1_DSC_7702")
        XCTAssertEqual(item.link, "#1_https://www.flickr.com/photos/saltspringsailing/34193341504/")
        XCTAssertEqual(item.media["m"], "#1_https://farm5.staticflickr.com/4195/34193341504_739834c596_m.jpg")
        XCTAssertEqual(item.dateTaken, "#1_2017-05-20T11:31:06-08:00")
        XCTAssertEqual(item.photoDesc, "#1_Lore Ipsum")
        XCTAssertEqual(item.published, "#1_2017-06-01T19:15:37Z")
        XCTAssertEqual(item.author, "#1_nobody@flickr.com")
        XCTAssertEqual(item.authorId, "#1_51694109@N03")
        XCTAssertEqual(item.tags, "#1_ tag1 tag2")
        
    }
    
    func testParseFlickrFeedAsJsonData() {
    
        // prepare 
        let jsonData = TestUtils.loadJSONData(fileName: "two_items")!
        
        // execute
        let result = FlickrFeed.parse(feedAsJsonData: jsonData)
        
        // verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Uploads from everyone")
        XCTAssertEqual(result?.items.count, 2)
        
        let item1 = result!.items[0]
        let item2 = result!.items[1]
        
        XCTAssertEqual(item1.title, "DSC_7702")
        XCTAssertEqual(item1.link, "https://www.flickr.com/photos/saltspringsailing/34193341504/")
        XCTAssertEqual(item1.media["m"], "https://farm5.staticflickr.com/4195/34193341504_739834c596_m.jpg")
        XCTAssertEqual(item1.dateTaken, "2017-05-20T11:31:06-08:00")
        XCTAssertEqual(item1.photoDesc, " <p><a href=\"https://www.flickr.com/people/saltspringsailing/\">Saltspring Island Sailing Club</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/saltspringsailing/34193341504/\" title=\"DSC_7702\"><img src=\"https://farm5.staticflickr.com/4195/34193341504_739834c596_m.jpg\" width=\"240\" height=\"160\" alt=\"DSC_7702\" /></a></p> <p>© 2017, Matti Troyer</p>")
        XCTAssertEqual(item1.published, "2017-06-01T19:15:37Z")
        XCTAssertEqual(item1.author, "nobody@flickr.com (\"Saltspring Island Sailing Club\")")
        XCTAssertEqual(item1.authorId, "51694109@N03")
        XCTAssertEqual(item1.tags, "tag_1 tag_2")
    
        XCTAssertEqual(item2.title, "Blooming Cacti")
        XCTAssertEqual(item2.link, "https://www.flickr.com/photos/rgranroth/34193341974/")
        XCTAssertEqual(item2.media["m"], "https://farm5.staticflickr.com/4225/34193341974_3ae700e8b6_m.jpg")
        XCTAssertEqual(item2.dateTaken, "2017-06-02T09:12:28-08:00")
        XCTAssertEqual(item2.photoDesc, " <p><a href=\"https://www.flickr.com/people/rgranroth/\">RGranroth</a> posted a photo:</p> <p><a href=\"https://www.flickr.com/photos/rgranroth/34193341974/\" title=\"Blooming Cacti\"><img src=\"https://farm5.staticflickr.com/4225/34193341974_3ae700e8b6_m.jpg\" width=\"240\" height=\"160\" alt=\"Blooming Cacti\" /></a></p> <p>at Chicago Botanic. Rarely seen, amazing beauty</p>")
        XCTAssertEqual(item2.published, "2017-06-01T19:15:39Z")
        XCTAssertEqual(item2.author, "nobody@flickr.com (\"RGranroth\")")
        XCTAssertEqual(item2.authorId, "46680892@N04")
        XCTAssertEqual(item2.tags, "tag_A tag_B")
        
    }
    
    func testParseFeedFromServer() {
        
        // prepare
        let jsonData = TestUtils.loadJSONData(fileName: "response_from_server")!
        
        // execute
        let result = FlickrFeed.parse(feedAsJsonData: jsonData)
        
        // verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.items.count, 20)
        
    }

}
