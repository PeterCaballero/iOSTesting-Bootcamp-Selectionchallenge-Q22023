//
//  URLImage.swift
//  miniBootcampChallenge
//
//  Created by Pedro Cruz Caballero on 23/04/23.
//

import Foundation
import UIKit

enum ImageStatus : Int {
    case fetching = 0
    case stored
    case broken
}

struct URLImage {
    var status : ImageStatus
    var url: String
    var index: Int
    
    init(){
        self.status = .fetching
        self.url = ""
        self.index = 0
    }
    
    init(url: String){
        self.status = .fetching
        self.url = url
        self.index = 0
    }
    
    mutating func setStatus(_ status: ImageStatus){
        self.status = status
    }
    
    mutating func setIndex(_ index: Int){
        self.index = index
    }
    
}
