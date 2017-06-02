//
//  FeedItemDetailsViewController.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 02/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FeedItemDetailsViewController: UIViewController {

    private let disposeBag = DisposeBag()
    var imagesProvider: ImagesProvider?
    var feedItem: FlickFeedItemViewModel! {
        didSet {
            feedItem.titleText.subscribe( onNext: { [weak self] (title:String) in
                self?.navigationItem.title = title
            }).disposed(by: disposeBag)
        }
    }

    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var btnOpenBrowser: UIBarButtonItem! {
        didSet {
            guard btnOpenBrowser != nil else { return }
            btnOpenBrowser.rx
                .tap
                .subscribe( onNext: { [weak self] in
                
                guard
                    let strongSelf = self,
                    let browserURL = try? strongSelf.feedItem.linkURL.value() else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.open(browserURL,
                                              options: [:],
                                              completionHandler: nil)
                }
            }).disposed(by: disposeBag)
        }
    }
    
    @IBOutlet weak var btnShare: UIBarButtonItem! {
        didSet {
            guard btnShare != nil else { return }
            btnShare.rx
                .tap
                .subscribe( onNext: {  [weak self] in
                
                guard
                    let strongSelf = self,
                    let browserURL = try? strongSelf.feedItem.linkURL.value() else { return }
                
                DispatchQueue.main.async {
                    let shareController = UIActivityViewController(activityItems: [browserURL], applicationActivities: nil)
                    strongSelf.present(shareController, animated: true, completion: nil)
                    
                }
            }).disposed(by: disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageURL = try? feedItem.imageURL.value() {
            self.imagesProvider?(imageURL, { [weak self] (image:UIImage?) in
                self?.pictureImageView.setImage(image)
            })
        }


    }

}
