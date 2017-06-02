//
//  NetworkOperationsExecutor.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

public protocol NetworkOperationsExecutor {
    
    func execute(operation: @escaping NetworkOperationBlock)
    
}

public class DefaultNetworkOperationsExecutor: NetworkOperationsExecutor {

    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    public func execute(operation: @escaping NetworkOperationBlock) {
        
        DispatchQueue.main.async { [weak self] in
            guard let s = self else {
                return
            }
            operation(s.session)
        }
        
    }
    
}
