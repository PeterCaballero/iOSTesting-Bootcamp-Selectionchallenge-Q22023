//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        initOutlets()
    }
    
    func initOutlets(){
        let switchControl = UISwitch(frame: CGRect(x:0, y:0, width:35, height:35))
        switchControl.onTintColor = UIColor.red
        switchControl.setOn(true, animated: false)
        switchControl.addTarget(self, action: #selector(switchTapped(sender:)), for: .valueChanged)
        
        let someImage = UIImage(named: "imageThumb")!
        let someButton = UIBarButtonItem(image: someImage,  style: .plain, target: self, action: #selector(someButtonTapped(sender:)))
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: switchControl),someButton]
    }
    
    
    @objc func switchTapped(sender: UIBarButtonItem) {
        print("switchTapped")
    }
    
    
    @objc func someButtonTapped(sender: UIBarButtonItem) {
        print("someButtonTapped")
    }
    
}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way

// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.


// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        let url = urls[indexPath.row]
        print("URL: \(url)")
        
        
        /*
        DispatchQueue.global().async { [weak self] in
            if let cachedImage = self?.imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
                cell.display(cachedImage)
            } else {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async {
                        let imageToCache = UIImage(data: data)
                        self?.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                        cell.display(imageToCache)
                    }
                }.resume()
            }
        }
        */
        
        
        /*
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView.downloaded(from: url)
                    }
                }
            }
        }
        */
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    //cell.display(UIImage.gifWithName("imageLoader"))
                    cell.imageView.downloaded(from: url)
                }
            }
        }
        
        
        /*
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.display(image)
                    }
                }
            }
        }
        */
        
        
        return cell
    }
    
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
    
    
    
   
    
    
}



class CustomImageView: UIImageView {
    
    // MARK: - Constants
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    // MARK: - Properties
    
    var imageURLString: String?
    
    func downloadImageFrom(urlString: String, imageMode: UIView.ContentMode) {
        guard let url = URL(string: urlString) else { return }
        downloadImageFrom(url: url, imageMode: imageMode)
    }
    
    func downloadImageFrom(url: URL, imageMode: UIView.ContentMode) {
        //contentMode = imageMode
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    self.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                    self.image = imageToCache
                }
            }.resume()
        }
    }
}
