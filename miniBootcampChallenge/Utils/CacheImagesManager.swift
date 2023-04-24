//
//  CacheImagesManager.swift
//  miniBootcampChallenge
//
//  Created by Pedro Cruz Caballero on 23/04/23.
//

import Foundation
import UIKit

class CacheImagesManager {
    
    static var imageCache = NSCache<NSString, UIImage>()
    
    static func getImage(key:String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    static func storeImage(key:String, img:UIImage){
        imageCache.setObject(img, forKey: key as NSString)
    }
    
}
