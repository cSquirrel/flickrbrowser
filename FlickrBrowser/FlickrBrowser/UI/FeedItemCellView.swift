//
//  FeedItemCellView.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 01/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import RxSwift

class FeedItemCellView: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    private let disposeBag = DisposeBag()
    public private(set) var feedItem:FlickFeedItemViewModel?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load(item: FlickFeedItemViewModel, imagesProvider: ImagesProvider) {
        
        self.feedItem = item
        
        item.titleText.bind(to: title.rx.text).disposed(by:disposeBag)
        item.dateText.bind(to: date.rx.text).disposed(by:disposeBag)
        
        
        imagesProvider(try! item.imageURL.value()) {(image: UIImage?) in
            DispatchQueue.main.async {
                // seems like the feed serves small scale images
                // if the images would be high res the scaling here would be
                // more beneficial by reducing the memory footprint
                self.photoImageView.setImage(image)
                self.photoImageView.setNeedsLayout()
            }
        }

    }

}
