//
//  UIImage+Cache.swift
//  miniBootcampChallenge
//
//  Created by Pedro Cruz Caballero on 19/04/23.
//

import Foundation
import UIKit

extension UIImageView{
    func setImageFromURL(_ url: URL){
        DispatchQueue.global(qos: .userInitiated ).async{
            
            if let data = NSData(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data as Data)
                }
            }else{
                self.image = UIImage(named: "imageThumb")
            }
        }
    }
    
    
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else {
            print("URL error: \(urlString )")
            return
        }
        
        let activityView = UIActivityIndicatorView(style: .medium)
        self.addSubview(activityView)
        activityView.frame = self.bounds
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityView.startAnimating()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                activityView.stopAnimating()
                activityView.removeFromSuperview()
            }
            
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
    
}




extension UIImageView {
    
    func downloaded(from url: URL,index: Int, contentMode mode: ContentMode = .scaleToFill){
        var fetched = false
        contentMode = mode
        image = UIImage.gifWithName("imageLoader")
   
        
        if let cachedImage = CacheImagesManager.getImage(key: url.absoluteString) {
            DispatchQueue.main.async() { [weak self] in
                if URLImagesManager.shared.fetchAll {
                    URLImagesManager.shared.setImageStatusWith(url: url.absoluteString, status: .stored, index: index)
                    
                    if URLImagesManager.shared.wereAllImagesFetched() {
                        self?.image = cachedImage
                    }
                }else{
                    self?.image = cachedImage
                }
            }
        }else{
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        DispatchQueue.main.async() { [weak self] in
                            URLImagesManager.shared.setImageStatusWith(url: url.absoluteString , status: .broken,index: index)
                            fetched = true
                            self?.image = UIImage(named: "imageThumb")
                        }
                        return
                    }
                                
                DispatchQueue.main.async() { [weak self] in
                    let urlString = url.absoluteString
                    
                    CacheImagesManager.storeImage(key: urlString, img: image)
                    URLImagesManager.shared.setImageStatusWith(url: urlString, status: .stored,index: index)
                    
                    if URLImagesManager.shared.fetchAll {
                        if URLImagesManager.shared.wereAllImagesFetched() {
                            
                            self?.image = image
                            
                        }
                    }else{
                        self?.image = image
                    }
                    
                    
                }
            }.resume()
            
        }
        
    }
        
        
    func downloaded(from link: String, index: Int, contentMode mode: ContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url,index: index, contentMode: mode)
    }
}
