//
//  UIImageView+Extensions.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 24/05/2017.
//  Copyright © 2017 Blue Pocket Limited. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /**
     * Redraw image to match image view's bound's size.
     * This method reduces memory consumption when setting large image.
     */
    func setImage(_ image: UIImage?, scale scaleImage: Bool = true) {
        
        guard let img = image else {
            return
        }
        
        guard scaleImage else {
            self.image = image
            return
        }
        
        let imgScale:CGFloat
        let originalImageSize = img.size
        if (self.bounds.size.width > self.bounds.size.height) {
            imgScale = self.bounds.size.width / originalImageSize.width
        } else {
            imgScale = self.bounds.size.height / originalImageSize.height
        }
        
        let hasAlpha = false
        // Apple doc: If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
        let scale: CGFloat = 0.0
        
        let imgSize = CGSize(width: floor(originalImageSize.width * imgScale),
                             height: floor(originalImageSize.height * imgScale))
        UIGraphicsBeginImageContextWithOptions(imgSize, !hasAlpha, scale)
        img.draw(in: CGRect(origin: CGPoint.zero, size: imgSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = scaledImage
    }
}
