//
//  MockNetworkOperationsExecutor.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 23/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit
@testable import FlickrBrowser
import RxSwift
import RxCocoa

class MockNetworkOperationsExecutor: NetworkOperationsExecutor {

    func execute(operation: @escaping NetworkOperationBlock) {
        operation(URLSession())
    }
}
