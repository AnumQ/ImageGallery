//
//  ViewController.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class ImageGalleryController: UICollectionViewController {

    
    fileprivate let reuseIdentifier = "reusableCell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    var flickrImages: [FlickrImage]!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSpinner()
        ApiManager.sharedInstance.fetchImages { xml, err in
            
            guard let xmlData = xml else { return LOG.error(err as Any) }
            
            guard let entries = xmlData[Constants.feed][Constants.entry] as XML.Accessor? else {
                return LOG.error("Unable to parse \(Constants.entry)")
            }
            
            self.flickrImages = []
            
            for entry in entries {

                guard let flickrImage = Parser.parseEntryToFlickrImage(entry: entry) else {
                    return
                }
                self.flickrImages.append(flickrImage)
            }
            
            self.stopSpinner()
            self.collectionView?.reloadData()
        }
    }
}

//MARK: Spinner
extension ImageGalleryController {
    func startSpinner() {
        view.addSubview(activityIndicator)
        activityIndicator.frame = (collectionView?.bounds)!
        activityIndicator.startAnimating()
    }
    
    func stopSpinner() {
        activityIndicator.removeFromSuperview()
    }
}

// MARK: UICollectionViewDataSource
extension ImageGalleryController {
    //1
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return flickrImages != nil ? flickrImages.count : 0
    }
    
    //3
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! FlickrCell
        cell.backgroundColor = UIColor.black
        cell.imageView.downloadedFrom(link: self.flickrImages[indexPath.row].imageUrl)
        // Configure the cell
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ImageGalleryController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

