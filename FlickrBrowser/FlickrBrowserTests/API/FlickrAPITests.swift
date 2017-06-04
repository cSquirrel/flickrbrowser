//
//  FlickrAPITests.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 22/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import XCTest
@testable import FlickrBrowser
import RxSwift
import RxCocoa

class FlickrAPIConfigTests: XCTestCase {
    
    func testCreateEndpointURL() {
        
        // prepare
        let baseURL = URL(string:"https://api.flickr.com/services/feeds")!
        let config = FlickrAPIConfig(networkProvider: MockNetworkServicesProvider(),
                                        networkExecutor: MockNetworkOperationsExecutor(),
                                        baseURL: baseURL)
    
        // execute
        let result = config.createEndpointURL(service: .publicPhotos)
        
        // verify
        let components = URLComponents.init(url: result, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.host, "api.flickr.com")
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.path, "/services/feeds/photos_public.gne")
        XCTAssertEqual(components?.queryItems?.count, 2)
    }
    
    func testCreateEndpointURL_WithQueryParams() {
        
        // prepare
        let baseURL = URL(string:"https://api.flickr.com/services/feeds")!
        let config = FlickrAPIConfig(networkProvider: MockNetworkServicesProvider(),
                                        networkExecutor: MockNetworkOperationsExecutor(),
                                        baseURL: baseURL)
        
        // execute
        let result = config.createEndpointURL(service: .publicPhotos, queryParams:["key1":"value1",
                                                                                        "key2":"value2"])
        
        // verify
        let components = URLComponents.init(url: result, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.host, "api.flickr.com")
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.path, "/services/feeds/photos_public.gne")
        XCTAssertEqual(components?.queryItems?.count, 4)
        
    }
}

class PublicPhotosAPIQueryTests: XCTestCase {
    
    func testQueryWithUserId() {
        
        // prepare
        let query = PublicPhotosAPIQuery(userId: "user_id")
        
        // execute
        let result = query.queryParams
        
        // validate
        XCTAssertEqual(result.keys.count, 1)
        XCTAssertEqual(result["id"], "user_id")
    }
    
    func testMultipleUserIds() {
        
        // prepare
        let query = PublicPhotosAPIQuery(multipleUserIds:["user_id_1","user_id_2"])
        
        // execute
        let result = query.queryParams
        
        // validate
        XCTAssertEqual(result.keys.count, 1)
        XCTAssertEqual(result["ids"], "user_id_1,user_id_2")
    }
    
    func testQueryWithAllTags() {
        
        // prepare
        let query = PublicPhotosAPIQuery(tags:["tag_1","tag_2"])
        
        // execute
        let result = query.queryParams
        
        // validate
        XCTAssertEqual(result.keys.count, 2)
        XCTAssertEqual(result["tags"], "tag_1,tag_2")
        XCTAssertEqual(result["tagmode"], "ALL")
    }
    
    func testQueryWithAnyTags() {
        
        // prepare
        let query = PublicPhotosAPIQuery(tags:["tag_1","tag_2"], tagmode: .any)
        
        // execute
        let result = query.queryParams
        
        // validate
        XCTAssertEqual(result.keys.count, 2)
        XCTAssertEqual(result["tags"], "tag_1,tag_2")
        XCTAssertEqual(result["tagmode"], "ANY")
    }
}

class FlickrAPITests: XCTestCase {
    
    var api: FlickrAPI!
    var networkServicesProvider: MockNetworkServicesProvider!
    
    override func setUp() {
        super.setUp()
        
        networkServicesProvider = MockNetworkServicesProvider()
        let e = MockNetworkOperationsExecutor()
        let config = FlickrAPIConfig(networkProvider: networkServicesProvider,
                                        networkExecutor: e,
                                        baseURL: URL(string:"http://bbc.co.uk/api")!)
        api = FlickrAPI(config)
    }
    
    override func tearDown() {
        super.tearDown()
        api = nil
    }
    
    func testGetPublicPhotos() {
        
        // prepare
        let jsonData = TestUtils.loadJSONData(fileName: "response_from_server")!
        networkServicesProvider.mockDataToReturn = jsonData
        
        var returnedFeed:FlickrFeed? = nil
        let shouldReturnFeed = expectation(description: "Should return feed")
        let result:FlickrAPI.GetPublicPhotosResult = {(feed: FlickrFeed) in
            returnedFeed = feed
            shouldReturnFeed.fulfill()
        }
        let error:FlickrAPI.ApiError = { (error: Error?) in }
        
        // execute
        api.getPublicPhotos(query: .init(), result: result, error: error)
        wait(for: [shouldReturnFeed], timeout: 2)
        
        // verify
        XCTAssertEqual(returnedFeed?.items.count, 20)

    }
    
    func testGetPublicPhotos_RequestedURL() {
        
        // prepare
        let jsonData = TestUtils.loadJSONData(fileName: "response_from_server")!
        networkServicesProvider.mockDataToReturn = jsonData
        
        let shouldReturnFeed = expectation(description: "Should return feed")
        let result:FlickrAPI.GetPublicPhotosResult = {(feed: FlickrFeed) in
            shouldReturnFeed.fulfill()
        }
        let error:FlickrAPI.ApiError = { (error: Error?) in }
        
        // execute
        api.getPublicPhotos(query: .init(), result: result, error: error)
        wait(for: [shouldReturnFeed], timeout: 2)
        
        // verify
        let requestedURL = networkServicesProvider.lastRequestedURL
        XCTAssertNotNil(requestedURL)
        let components = URLComponents(url: requestedURL!, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.host, "bbc.co.uk")
        XCTAssertEqual(components?.scheme, "http")
        XCTAssertEqual(components?.path, "/api/photos_public.gne")
        XCTAssertEqual(components?.queryItems?.count, 2)
        
        var queryParams:[String:String] = [:]
        components!.queryItems!.forEach { queryParams[$0.name] = $0.value }
        XCTAssertEqual(queryParams["format"], "json")
        XCTAssertEqual(queryParams["nojsoncallback"], "1")

    }
    
}
