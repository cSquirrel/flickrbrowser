//
//  MockNetworkServicesProvider.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit
@testable import FlickrBrowser
import RxSwift
import RxCocoa

class MockNetworkServicesProvider: NetworkServicesProvider {

    var mockDataToReturn = Data()
    var lastRequestedURL: URL?
    
    func createGETOperation(url: URL, operationResult result: @escaping NetworkOperationResult) -> NetworkOperationBlock {
        
        return { [unowned self] _ in
            self.lastRequestedURL = url
            result( .successful(self.mockDataToReturn) )
        }
    }
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) -> NetworkOperationBlock {
        
        return { [unowned self] _ in
            self.lastRequestedURL = url
            completion(nil)
        }
        
    }
    
}
