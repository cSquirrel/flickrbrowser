//
//  FeedItemsTableViewController.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 01/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FeedItemsTableViewController: UITableViewController {

    enum Const {
        static let cellId = "FeedItemCell"
        static let showDetailsSegue = "showDetails"
    }
    
    @IBOutlet var applicationConfiguration: ApplicationConfiguration!
    
    var flickrFeed: BehaviorSubject<[FlickFeedItemViewModel]> = BehaviorSubject(value: Array())
    private let disposeBag = DisposeBag()
    fileprivate let spinnerView = LoadingSpinnerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // safety precaution
        tableView.dataSource = nil
        tableView.delegate = nil
        
        flickrFeed.asObservable().bind(to: tableView.rx.items(cellIdentifier: Const.cellId, cellType: FeedItemCellView.self)) {
            [weak self] (index, feedItem:FlickFeedItemViewModel, cell) in
            
            guard let strongSelf = self else { return }
            cell.load(item: feedItem, imagesProvider: strongSelf.applicationConfiguration.imagesProvider)
            
        }.disposed(by:disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe( onNext: { (indexPath:IndexPath) in
                guard let selectedCell = self.tableView.cellForRow(at: indexPath) as? FeedItemCellView else {
                    return
                }
                let selectedValue = selectedCell.feedItem
                self.performSegue(withIdentifier: Const.showDetailsSegue, sender: selectedValue)
        }).disposed(by:disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        loadFeed()
    }
    
    
    private func loadFeed() {
        
        spinnerView.show(inView: self.view)
        let api = applicationConfiguration.apiAccess
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            api?.getPublicPhotos(query: PublicPhotosAPIQuery.empty,
                                 result: strongSelf.apiSuccess,
                                 error: strongSelf.apiFailure)
            
        }
        
    }
    
    func apiSuccess(flickrFeed fi: FlickrFeed) {
        
        DispatchQueue.main.async { [weak self] in
            self?.spinnerView.hide()
            self?.navigationItem.title = fi.title
        }
        
        let items = fi.items.flatMap { FlickFeedItemViewModel(feedItem: $0) }
        flickrFeed.on(.next(items))
        
    }
    
    func apiFailure(error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.spinnerView.hide()
            let alert = UIAlertController(title: "ERROR", message: "Unable to fetch feed data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let detailsController = segue.destination as? FeedItemDetailsViewController,
            let feedItem = sender as? FlickFeedItemViewModel else {
                return
        }
        
        detailsController.imagesProvider = applicationConfiguration.imagesProvider
        detailsController.feedItem = feedItem
    }
}
