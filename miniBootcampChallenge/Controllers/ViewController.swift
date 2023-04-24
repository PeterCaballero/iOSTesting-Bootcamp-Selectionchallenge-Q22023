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
    
    var updated : Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        initOutlets()
    }
    
    func initOutlets(){
        
        // Theres a switch at the top bar,
        // If is On, all urls has to be fetched in order to show collection item images
        // If switch is Off every single image will be shown as they are downloaded
        
        let switchControl = UISwitch(frame: CGRect(x:0, y:0, width:35, height:35))
        switchControl.onTintColor = UIColor.red
        switchControl.setOn(false, animated: false)
        switchControl.addTarget(self, action: #selector(switchTapped(sender:)), for: .valueChanged)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: switchControl)]
        
        URLImagesManager.shared.setDownloadType(allAtOnce: false)
        URLImagesManager.shared.loadImages()
    }
    
    
    @objc func switchTapped(sender: UISwitch) {
        print("switchTapped: \(sender.isOn)")
        fetchImages(allAtOnce: sender.isOn)
    }
    
    func fetchImages(allAtOnce: Bool){
        URLImagesManager.shared.setDownloadType(allAtOnce: allAtOnce)
        URLImagesManager.shared.loadImages()
        collectionView.reloadData()
    }
    
}


// TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way

// TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.




// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        URLImagesManager.shared.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        let urlString = URLImagesManager.shared.images[indexPath.row].url
        print("\(indexPath.item) URL: \(urlString)")
        
        DispatchQueue.global().async { [weak self] in
            if let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    URLImagesManager.shared.setVisibleMaxIndex(max: indexPath.item)
                    
                    cell.imageView.downloaded(from: url, index: indexPath.item)
                    
                    
                    print("\(indexPath.item) - \(URLImagesManager.shared.maxIndex)")
                    
                    
                    
                    if URLImagesManager.shared.fetchAll && cell.imageView != nil && indexPath.item ==  URLImagesManager.shared.maxIndex && ((self?.updated) != nil) {
                        
                        self?.updated = nil
                        collectionView.reloadData()
                        
                        
                    }
                      
                }
            }
        }
        
        
        return cell
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
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)
            print("Last indexPath \(indexPath?.item)")
            URLImagesManager.shared.setVisibleMinIndex(min: indexPath?.item ?? 1)
            
            self.updated = 0
            
        }
    }
    
}

