//
//  URLImagesManager.swift
//  miniBootcampChallenge
//
//  Created by Pedro Cruz Caballero on 23/04/23.
//

import Foundation
import UIKit


class URLImagesManager{
    
    static let shared = URLImagesManager()
    var fetchAll : Bool = false
    var images: [URLImage] = []
    var minIndex : Int = 0
    var maxIndex : Int = 0
        
    //Initializer access level change now
    private init(){}
    
    func setDownloadType(allAtOnce: Bool){
        fetchAll = allAtOnce
        if fetchAll {setVisibleMinIndex(min: 0)}
    }
    
    func loadImages(){
        images = URLProvider.loadImagesData(fetchAll: self.fetchAll)
        print("Images URLs loaded")
    }
    
    func setImageStatusWith(url: String, status: ImageStatus, index: Int){
        guard let index = images.firstIndex(where: {$0.url == url}) else{ return }
        images[index].setStatus(status)
        images[index].setIndex(index)
    }

    
    func setVisibleMinIndex(min mini:Int){
        minIndex = mini
    }
    
    func setVisibleMaxIndex(max maxi: Int){
        maxIndex = maxi
    }
    
    func wereAllImagesFetched() -> Bool{
        var indexRange = 0...1
        if self.minIndex > self.maxIndex{
            let aux = minIndex
            minIndex = maxIndex
            maxIndex = aux
        }
        
        indexRange = self.minIndex...self.maxIndex
        
        let filteredArray = images.filter {
            indexRange.contains($0.index)
            && ($0.status == .stored
            || $0.status == .broken)
        }
        
        return filteredArray.count == indexRange.count
    }
    
    
    
}
