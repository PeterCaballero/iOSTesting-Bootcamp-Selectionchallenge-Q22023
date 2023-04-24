//
//  URLProvider.swift
//  miniBootcampChallenge
//

import Foundation
import UIKit

struct URLProvider {
    
   
    static func loadURLS()-> [URL] {
        guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
              let contents = try? Data(contentsOf: plist),
              let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
              let serialUrls = serial as? [String] else { return [] }
        return serialUrls.compactMap { URL(string: $0) }
    }
    
    
    static func loadImagesData(fetchAll: Bool)-> [URLImage]{
        var serialUrls = self.loadURLS()
        var urlImagesArray: [URLImage] = []
        for url in serialUrls {
            urlImagesArray.append(URLImage(url:url.absoluteString))
        }
        
        return urlImagesArray
    }
}

