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

class ImageGalleryController: UICollectionViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    var context: NSManagedObjectContext!
    fileprivate let reuseIdentifier = "reusableCell"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    @IBOutlet weak var searchField: UITextField!
  //  fileprivate var flickrImages: [FlickrImageModel]!
  //  fileprivate var allImages: [FlickrImageModel]!
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        let predicate:NSPredicate! = nil //NSPredicate(format: "title == %@", "Glimt fra båthavna i Skjelanger")
        self.fetchedResultsController = createFetchController(predicate: predicate)
        
        getAllDataFromStorage()
        //startSpinner()
        
        getImagesFromStorage()
        
        getImagesFromFlickr()
    }
    
    func createFetchController(predicate: NSPredicate?) -> NSFetchedResultsController<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.FlickrImage)
        let primarySortDescriptor = NSSortDescriptor(key: "title.order", ascending: true)
        request.sortDescriptors = [primarySortDescriptor]
        if predicate != nil {
            request.predicate = predicate
        }
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }
    
    func getAllDataFromStorage() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            LOG.error("Failed to perform fetch")
        }
    }
    
    
    
    func getImagesFromFlickr() {
        ApiManager.sharedInstance.fetchImages { xml, err in
            guard let xmlData = xml else { return LOG.error(err as Any) }
            guard let entries = xmlData[Constants.feed][Constants.entry] as XML.Accessor? else {
                return LOG.error(Failed.toParse + Constants.entry)
            }
            
          //  self.flickrImages = []
            for entry in entries {
                guard let flickrImage = Parser.parseEntryToFlickrImage(entry: entry) else {
                    return
                }
                Storage.addImage(flickrImage: flickrImage)
              //  self.flickrImages.append(flickrImage)
            }
            
            self.stopSpinner()
            
          //  self.allImages = self.flickrImages
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
//            for flickrImage in self.flickrImages {
//                Storage.addImage(flickrImage: flickrImage)
//            }
        }
    }
    
    func getImagesFromStorage() {
        let images:[FlickrImage]? = Storage.getImages()
        if images != nil {
            var imagesFromStorage: [FlickrImageModel] = []
            for image:FlickrImage in images! {
                let flickrImageModel = Parser.parseFlickrImageToModel(flickrImage: image)
                imagesFromStorage.append(flickrImageModel)
            }
     //       self.allImages = imagesFromStorage
      //      self.flickrImages = imagesFromStorage
            self.stopSpinner()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        
        if sender.text != nil && !sender.text!.isEmpty {
            let search = sender.text!
            
            let predicate = NSPredicate(format: "title == %@", search)
            self.fetchedResultsController = createFetchController(predicate: predicate)
            
            getAllDataFromStorage()
           let data = self.fetchedResultsController.fetchedObjects as? [FlickrImage]
            
            print(1)
//            
//            let filtered = data.filter({ ($0.tags as! [String]).contains(where: {
//                $0.range(of: search, options: .caseInsensitive) != nil
//                })
//            })
//            
//            print(filtered)
            
           // self.flickrImages = filtered
            self.collectionView?.reloadData()
        } else {
           // self.flickrImages = allImages
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
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        //return flickrImages != nil ? flickrImages.count : 0
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    //3
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! FlickrCell
        cell.backgroundColor = UIColor.white
        
        let flickrImage = fetchedResultsController.object(at: indexPath) as! FlickrImage
        let flickrImageModel = Parser.parseFlickrImageToModel(flickrImage: flickrImage)
        cell.imageView.image = flickrImageModel.image
        let tags = flickrImageModel.tags
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
