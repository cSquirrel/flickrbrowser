//
//  DefaultServicesProvider.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

class DefaultServicesProvider: NetworkServicesProvider {

    /**
     * In this coding excercise there's no big benefit of supplying cache externally
     * but in the future NSCache can be replaced by a protocol implemented with many
     * different persitence and eviction strategies
     */
    var imageCache:NSCache<NSURL, UIImage>?
    var jsonCache:NSCache<NSURL, NSData>?

    func createGETOperation(url: URL, operationResult result: @escaping NetworkOperationResult) -> NetworkOperationBlock {
        
        if let cachedData = jsonCache?.object(forKey: url as NSURL) as Data? {
            DispatchQueue.global(qos:.default).async {result( .successful(cachedData) )}
            return { _ in }
        }
        
        return { [weak self] (session: URLSession) in
            
            let dataTask = session.dataTask(with: url, completionHandler: {
                (responseData: Data?, urlResponse: URLResponse?, responseError: Error?) in
                
                guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                    DispatchQueue.global(qos:.default).async { result( .failed(responseError)) }
                    return
                }
                
                guard let rData = responseData else {
                    DispatchQueue.global(qos:.default).async { result( .failed(responseError)) }
                    return
                }
                
                let resultBlock: () -> ()
                let statusCode = httpUrlResponse.statusCode
                switch statusCode {
                    case 200 ... 299:
                        self?.jsonCache?.setObject(rData as NSData, forKey: url as NSURL)
                        resultBlock = {result( .successful(rData) )}
                    default:
                        resultBlock = {result( .failed(responseError) )}
                }
                
                DispatchQueue.global(qos:.default).async( execute: resultBlock )
                
            })
            dataTask.resume()
        }
    }
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) -> NetworkOperationBlock {
        
        if let cachedImage = imageCache?.object(forKey: url as NSURL) {
            DispatchQueue.global(qos:.default).async { completion(cachedImage) }
            return { _ in }
        }
        
        return { [weak self] (session: URLSession) in
            
            let dataTask = session.dataTask(with: url, completionHandler: {
                (responseData: Data?, urlResponse: URLResponse?, responseError: Error?) in
                
                if let rData = responseData {
                    let image = UIImage(data: rData)
                    if image != nil {
                        self?.imageCache?.setObject(image!, forKey: url as NSURL)
                    }
                    DispatchQueue.global(qos:.default).async { completion(image) }
                } else {
                    DispatchQueue.global(qos:.default).async { completion(nil) }
                }
                
            })
            dataTask.resume()
        }
    }
}
