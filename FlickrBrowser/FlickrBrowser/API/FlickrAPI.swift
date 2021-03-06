//
//  FlickrAPI.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 22/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

/**
 *
 * See: https://www.flickr.com/services/feeds/docs/photos_public
 * See: https://www.flickr.com/services/feeds/
 * See: https://www.flickr.com/services/api/response.json.html
 */
struct FlickrAPIConfig {
    
    let networkProvider: NetworkServicesProvider
    let networkExecutor: NetworkOperationsExecutor
    let baseURL: URL
    
    public func createEndpointURL(servicePath: String, queryParams: [String:String]? = nil) -> URL {
        
        var result = URL(string:baseURL.absoluteString)!
        result.appendPathComponent(servicePath)
        if let query = queryParams {
            let queryParamsString = query.map({ return "\($0)=\($1)" }).joined(separator: "&")
            var components = URLComponents(url: result, resolvingAgainstBaseURL: true)!
            components.query = queryParamsString
            result = components.url!
        }
        return result
    }
    
}

public struct PublicPhotosAPIQuery {
    
    public static let empty = PublicPhotosAPIQuery()
    
    public enum PublicPhotosAPIQueryTagmode: String {
        case all = "ALL"
        case any = "ANY"
    }
    
    public private(set) var queryParams: [String:String]
    
    public init() {
        self.init(queryParams: [:])
    }
    
    private init(queryParams qp: [String:String]) {
        queryParams = qp
    }
    
    /**
     * userId: A single user ID. This specifies a user to fetch for.
     */
    public init(userId: String) {
        self.init(queryParams: ["id":userId])
    }
    
    /**
     * multipleUserIds: list of user IDs. This specifies a list of users to fetch for.
     */
    public init(multipleUserIds: [String]) {
        let queryParamValue = multipleUserIds.joined(separator: ",")
        self.init(queryParams: ["ids":queryParamValue])
    }
    
    /**
     * tags: A comma delimited list of tags to filter the feed by.
     * tagmode: Control whether items must have ALL the tags (tagmode=all), or ANY (tagmode=any) of the tags. Default is ALL.
     */
    public init(tags: [String], tagmode: PublicPhotosAPIQueryTagmode = .all) {
        let tagsJoined = tags.joined(separator: ",")
        var params:[String:String] = [:]
        params["tags"] = tagsJoined
        params["tagmode"] = tagmode.rawValue
        self.init(queryParams: params)
    }
    
}

public class FlickrAPI: NSObject {

    enum Const {
        
        static let formatQueryParam = "format"
        static let formatQueryValue = "json"
        static let callbackQueryParam = "nojsoncallback"
        static let callbackQueryValue = "1"
        static let endpointPublicPhotos = "photos_public.gne"
        
    }
    
    private let config: FlickrAPIConfig
    
    init(_ c: FlickrAPIConfig) {
        
        config = c
        
    }
    
    public typealias ApiError = (_ error: Error?) -> ()
    
    public typealias GetPublicPhotosResult = (_ flickrFeed: FlickrFeed) -> ()
    public func getPublicPhotos(query:PublicPhotosAPIQuery,
                                result: @escaping GetPublicPhotosResult,
                                error: @escaping ApiError) {
        
        let result = { (status: NetworkOperationStatus) in
            
            switch status {
            case .successful(let data):
                if let flickrFeed = FlickrFeed.parse(feedAsJsonData: data) {
                    result(flickrFeed)
                } else {
                    error(nil)
                }
            case.failed:
                error(nil)
                return
            }
        }
        
        var queryParams = query.queryParams
        queryParams[Const.formatQueryParam] = Const.formatQueryValue
        queryParams[Const.callbackQueryParam] = Const.callbackQueryValue
        let endpointURL = config.createEndpointURL(servicePath: Const.endpointPublicPhotos, queryParams: queryParams)
        let getProductsOp = config.networkProvider.createGETOperation(url: endpointURL, operationResult: result)
        config.networkExecutor.execute(operation: getProductsOp)
        
    }

}
