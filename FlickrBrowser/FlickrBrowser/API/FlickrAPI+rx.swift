//
//  FlickrAPI+rx.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 04/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: FlickrAPI {
    
    public var allPublicPhotos: Observable<FlickrFeed> {
        return getPublicPhotos(query: PublicPhotosAPIQuery.empty)
    }
    
    public func getPublicPhotos(query: PublicPhotosAPIQuery) -> Observable<FlickrFeed> {
        
        return Observable.create { (observer: AnyObserver<FlickrFeed>) -> Disposable in
            
            let disposeBag = DisposeBag()
            Observable
                .just(query)
                .map({ (query: PublicPhotosAPIQuery) -> [String:String] in
                    return query.queryParams
                })
                .map({ (queryParams: [String : String]) -> URL in
                    let endpointURL = self.base.config.createEndpointURL(service: .publicPhotos, queryParams: queryParams)
                    return endpointURL
                })
                .map({ (serviceURL: URL) -> NetworkOperationBlock in
                    self.base.config.networkProvider.createGETOperation(url: serviceURL, operationResult: { (operationStatus: NetworkOperationStatus) in
                        FlickrAPI.rx.retrievedPublicPhotos(observer: observer, status: operationStatus)
                    })
                })
                .subscribe(onNext: { (operation: @escaping NetworkOperationBlock) in
                    self.base.config.networkExecutor.execute(operation: operation)
                }).disposed(by: disposeBag)
            
            
            return Disposables.create()
        }
        
    }

    static func retrievedPublicPhotos(observer: AnyObserver<FlickrFeed>, status: NetworkOperationStatus) {
        switch status {
        case .successful(let data):
            if let flickrFeed = FlickrFeed.parse(feedAsJsonData: data) {
                observer.onNext(flickrFeed)
            } else {
                observer.onError(FlickrAPIError.jsonDeserialisationError)
            }
        case .failed(let error):
            let err = error ?? FlickrAPIError.unknownError
            observer.onError(err)
            return
        }
    }
}
