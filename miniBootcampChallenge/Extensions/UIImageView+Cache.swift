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
    
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleToFill) {
        contentMode = mode
        image = UIImage.gifWithName("imageLoader")
        
        
        let imageCache = NSCache<NSString, UIImage>()
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async() { [weak self] in
                self?.image = cachedImage
            }
        }else{
            /*
            //Test broken link
            let urlFinal = String(url.absoluteString.dropFirst())
            print(urlFinal)
            let URLFF = URL(string: urlFinal)
             URLSession.shared.dataTask(with: URLFF!) { data, response, error in
            */
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        DispatchQueue.main.async() { [weak self] in
                            self?.image = UIImage(named: "imageThumb")
                        }
                        return
                    }
                
                
                DispatchQueue.main.async() { [weak self] in
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    self?.image = image
                }
            }.resume()
        }
    }
        
        
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
