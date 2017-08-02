//
//  ViewController.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import UIKit
import SwiftyXMLParser
import CoreData

class ImageGalleryController: UICollectionViewController, UITextFieldDelegate {

    fileprivate let reuseIdentifier = "reusableCell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    @IBOutlet weak var searchField: UITextField!
    fileprivate var flickrImages: [FlickrImageModel]!
    fileprivate var allImages: [FlickrImageModel]!
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImagesFromStorage()
        
        getImagesFromFlickr()
    }
    
    func getImagesFromFlickr() {
        ApiManager.sharedInstance.fetchImages { xml, err in
            guard let xmlData = xml else { return LOG.error(err as Any) }
            guard let entries = xmlData[Constants.feed][Constants.entry] as XML.Accessor? else {
                return LOG.error(Failed.toParse + Constants.entry)
            }
            
            self.flickrImages = []
            for entry in entries {
                guard let flickrImage = Parser.parseEntryToFlickrImage(entry: entry) else {
                    return
                }
                self.flickrImages.append(flickrImage)
            }
            
            self.stopSpinner()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            self.allImages = self.flickrImages
            
            for flickrImage in self.flickrImages {
                Storage.addImage(flickrImage: flickrImage)
            }
        }
    }
    
    func getImagesFromStorage() {
        startSpinner()
        
        let images:[FlickrImage]? = Storage.getImages()
        if images != nil {
            var imagesFromStorage: [FlickrImageModel] = []
            for image:FlickrImage in images! {
                let flickrImageModel = Parser.parseFlickrImageToModel(image: image)
                if flickrImageModel != nil {
                    imagesFromStorage.append(flickrImageModel!)
                }
            }
            self.allImages = imagesFromStorage
            self.flickrImages = imagesFromStorage
            self.stopSpinner()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        if sender.text != nil && !sender.text!.isEmpty {
            let search = sender.text!
            
            let filtered = self.allImages.filter({ $0.tags.contains(where: {
                $0.range(of: search, options: .caseInsensitive) != nil
                })
            })
            
            self.flickrImages = filtered
            self.collectionView?.reloadData()
        } else {
            self.flickrImages = allImages
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
        cell.backgroundColor = UIColor.white
        cell.imageView.image = self.allImages[indexPath.row].image
        let tags = self.allImages[indexPath.row].tags
        let tagsString = tags.reduce("", { $0 + $1 + ","})
        
        if tags.count > 0 {
            let removeTheLastCharacterInTagsString = tagsString.substring(to: tagsString.index(before: tagsString.endIndex))
            cell.tagsLabel.text = removeTheLastCharacterInTagsString
        }
        
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
