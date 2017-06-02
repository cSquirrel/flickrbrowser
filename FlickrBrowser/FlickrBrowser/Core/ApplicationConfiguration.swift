//
//  ApplicationConfiguration.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

/**
 * The reason why images provider does not belong to the networking layer is
 * that although images can be provided through network layer, they may also be provided
 * in any other way ( cache, local file ).
 */
typealias ImagesProvider = (_ url: URL?, _ completion: @escaping (UIImage?) -> Void) -> ()

class ApplicationConfiguration: NSObject {
    
    private(set) var apiAccess: FlickrAPI!
    private(set) var imagesProvider: ImagesProvider!
    
    override func awakeFromNib() {
        createApiAccess()
    }
    
    fileprivate func createApiAccess() {
        
        let networkProvider = DefaultServicesProvider()
        // NOTE: See my comment on the properties
        networkProvider.imageCache = NSCache<NSURL, UIImage>()
        networkProvider.jsonCache = NSCache<NSURL, NSData>()
        let networkExecutor = DefaultNetworkOperationsExecutor(configuration: .default)
        
        // These values are hardcoded here but should be provided from an external configuration file
        let baseURL = URL(string:"https://api.flickr.com/services/feeds/")!
        
        let apiConfig = FlickrAPIConfig(networkProvider: networkProvider,
                                           networkExecutor: networkExecutor,
                                           baseURL: baseURL)
        apiAccess = FlickrAPI(apiConfig)
        
        imagesProvider = { (url: URL?, completion: @escaping (UIImage?) -> Void) -> () in
            guard let urlToDownload = url else { completion(nil); return }
            let fetchImageOperation = networkProvider.fetchImage(url: urlToDownload, completion: completion)
            networkExecutor.execute(operation: fetchImageOperation)
        }
    }
}
