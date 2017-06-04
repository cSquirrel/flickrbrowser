//
//  Dictionary+Extensions.swift
//  FlickrBrowser
//
//  Created by Marcin Maciukiewicz on 04/06/2017.
//  Copyright © 2017 Marcin Maciukiewicz. All rights reserved.
//

import Foundation

extension Dictionary where Key : CustomStringConvertible, Value : CustomStringConvertible {

    /**
     Produce a new dictionary as a merge of self and other dictionary
     */
    func merge(withDictionary: Dictionary<Key, Value>?) -> Dictionary<Key, Value> {
        
        guard let otherDict = withDictionary else {
            return self
        }
        
        var result = self
        otherDict.keys.forEach { (key:Key) in
            result[key] = otherDict[key]
        }
        
        return result
    }
}
