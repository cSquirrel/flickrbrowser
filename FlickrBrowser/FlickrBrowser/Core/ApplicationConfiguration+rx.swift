//
//  ApplicationConfiguration+rx.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 04/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import Foundation

import RxSwift

typealias RxImagesProvider = (_ url: URL?) -> Observable<UIImage>

extension Reactive where Base: ApplicationConfiguration {
    
    var imagesProvider: RxImagesProvider {
        
        return { (url: URL?) -> Observable<UIImage> in
            
            guard let urlToDownload = url else { return Observable.never() }
            
            let result = Observable.create({ (observer: AnyObserver<UIImage>) -> Disposable in
                
                self.base.imagesProvider(urlToDownload) { (downloadedImage:UIImage?) in
                    
                    guard let img = downloadedImage else {
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(img)
                    observer.onCompleted()
                }
                
                return Disposables.create()
            })
            
            return result
        }
    }
}
