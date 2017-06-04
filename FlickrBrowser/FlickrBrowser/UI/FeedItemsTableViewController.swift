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
    
    var flickrFeed: Variable<[FlickFeedItemViewModel]> = Variable([])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        
        // safety precaution
        tableView.dataSource = nil
        tableView.delegate = nil
        
        // Bind the table to flickrFeed
        flickrFeed.asObservable().bind(to: tableView.rx.items(cellIdentifier: Const.cellId, cellType: FeedItemCellView.self)) {
            [weak self] (index, feedItem:FlickFeedItemViewModel, cell) in
            
            guard let strongSelf = self else { return }
            cell.load(item: feedItem, imagesProvider: strongSelf.applicationConfiguration.rx.imagesProvider)
            
        }.disposed(by:disposeBag)
        
        // Respond to item selection
        tableView.rx
            .itemSelected
            .flatMap({ (indexPath:IndexPath) -> Observable<FlickFeedItemViewModel> in
                guard let selectedCell = self.tableView.cellForRow(at: indexPath) as? FeedItemCellView,
                    let selectedFeedItem = selectedCell.feedItem else {
                    return Observable.never()
                }
                return Observable.just(selectedFeedItem)
            })
            .subscribe( onNext: { (selectedFeedItem:FlickFeedItemViewModel) in
                self.performSegue(withIdentifier: Const.showDetailsSegue, sender: selectedFeedItem)
        }).disposed(by:disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadFeed()
        }
    }
    
    func loadFeed() {
        
        guard let api = applicationConfiguration.apiAccess else { return }
        
        let apiAccess = api.rx.allPublicPhotos.shareReplay(1)
        
        // Feed items
        apiAccess
            .subscribe(onNext: { [weak self] feed in
                self?.flickrFeed.value = feed.items.flatMap {FlickFeedItemViewModel(feedItem: $0)}
            })
            .disposed(by: disposeBag)
        
        // Feed title
        apiAccess
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] feed in
                self?.navigationItem.title = feed.title
            })
            .disposed(by: disposeBag)
        
        // Feed failure
        apiAccess
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onError: { [weak self]  error in
                self?.showAlert(withError: error)
            })
            .disposed(by: disposeBag)
        
        // Finish refreshing
        apiAccess
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] event in
                self?.refreshControl?.endRefreshing()
            }
            .disposed(by: disposeBag)
    }
    
    func showAlert(withError: Error?) {
        
        let alert = UIAlertController(title: "ERROR", message: "Unable to fetch feed data", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let detailsController = segue.destination as? FeedItemDetailsViewController,
            let feedItem = sender as? FlickFeedItemViewModel else {
                return
        }
        
        detailsController.imagesProvider = applicationConfiguration.rx.imagesProvider
        detailsController.feedItem = feedItem
    }
}
