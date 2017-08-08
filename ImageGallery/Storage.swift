//
//  Storage.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 02/08/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

open class Storage {
    
    static func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    static func addImage(flickrImage: FlickrImageModel) {
        
        let context = getContext()
        
        let image = NSEntityDescription.insertNewObject(forEntityName: Entity.FlickrImage, into: context) as! FlickrImage
        image.setValue(flickrImage.title, forKey: Constants.title)
        image.setValue(flickrImage.imageUrl, forKey: Constants.imageUrl)
        image.setValue(flickrImage.tags, forKey: Constants.tags)
        
        
        let imageURL = URL(string: flickrImage.imageUrl)
        do {
            let data = try Data(contentsOf: imageURL! as URL)
            image.setValue(data, forKey: Constants.image)
        } catch {
            LOG.error(Failed.getImageData)
        }
        
        do {
            try context.save()
            LOG.info(Success.imageSaved + flickrImage.title)
        } catch {
            LOG.debug(Failed.saveImage)
        }
    }
    
    static func getImages() -> [FlickrImage]? {
        
//        let context = getContext()
//        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.FlickrImage)
//        request.returnsObjectsAsFaults = false
//        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        
//        let images: [FlickrImage]!
//        do {
//           // images = try context.fetch(request) as! [FlickrImage]
//            
//            try controller.performFetch()
//            //return images
//            
//        } catch {
//            LOG.debug(Failed.fetchImages)
//        }
//        return nil
        return nil
    }
    
    static func deleteAllImages(){
        
        let context = getContext()
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: Entity.FlickrImage))
        do {
            try context.execute(DelAllReqVar)
        }
        catch {
            LOG.debug(Failed.deleteImages)
        }
    }
}
