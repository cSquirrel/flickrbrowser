//
//  FlickFeedViewModel.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 02/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import RxSwift

struct FlickFeedItemViewModel {

    private var feedItem: FlickrFeedItem
    private let disposeBag = DisposeBag()
    
    var titleText: BehaviorSubject<String>
    var linkURL: BehaviorSubject<URL>
    var imageURL: BehaviorSubject<URL>
    var dateText: BehaviorSubject<String>
    
    init?(feedItem: FlickrFeedItem) {
        
        self.feedItem = feedItem
        
        titleText = BehaviorSubject<String>(value: feedItem.title)
        
        guard
            let lURL = URL(string:feedItem.link),
            lURL.scheme != nil,
            lURL.host != nil else {
            return nil
        }
        linkURL = BehaviorSubject<URL>(value: lURL)
        
        guard
            let firstMediaLink = feedItem.media.first,
            let iURL = URL(string:firstMediaLink.value),
            iURL.scheme != nil,
            iURL.host != nil else {
            return nil
        }
        imageURL = BehaviorSubject<URL>(value: iURL)
        
        dateText = BehaviorSubject<String>(value: feedItem.dateTaken)
    }
}
