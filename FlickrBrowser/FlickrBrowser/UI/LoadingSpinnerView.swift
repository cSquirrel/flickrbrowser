//
//  LoadingSpinnerView.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 01/06/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

class LoadingSpinnerView: UIView {
    
    private var isViewHidden = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        
        let selfType = type(of:self)
        let bundle = Bundle(for: selfType)
        let nib = UINib.init(nibName: "\(selfType)", bundle: bundle)
        let views = nib.instantiate(withOwner: self, options: nil)
        guard let view = views.first as? UIView else {
            return
        }
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func show(inView superview: UIView) {
        
        // Just in case 'show' is called multiple times
        if self.superview != nil {
            hide()
        }
        
        self.isViewHidden = false
        
        // This tiny delay will prevent spinner from flicking for a split second
        // if hide() is called immediately
        // This will happen when data is provided from cache
        let deadlineTime = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            
            guard let spinnerView = self else {
                return
            }
            
            // In case hide() was called already
            if spinnerView.isViewHidden { return }
            spinnerView.frame = superview.bounds
            superview.addSubview(spinnerView)
        }
    }
    
    func hide() {
        isViewHidden = true
        self.removeFromSuperview()
    }

}
