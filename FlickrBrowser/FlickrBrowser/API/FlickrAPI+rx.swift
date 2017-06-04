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
        return publicPhotos(query: PublicPhotosAPIQuery.empty)
    }
    
    public func publicPhotos(query: PublicPhotosAPIQuery) -> Observable<FlickrFeed> {
        
        return Observable.create { (observer: AnyObserver<FlickrFeed>) -> Disposable in
            
            self.base.getPublicPhotos(query: query, result: { (flickFeed: FlickrFeed) in
                observer.onNext(flickFeed)
                observer.onCompleted()
            }, error: { (error:Error?) in
                guard let err = error else {
                    observer.onCompleted()
                    return
                }
                observer.onError(err)
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
        
    }
    
}
