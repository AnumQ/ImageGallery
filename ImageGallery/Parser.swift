//
//  Parser.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation
import SwiftyXMLParser
import CoreData

class Parser {
    
    static func parseEntryToFlickrImage(entry: XML.Accessor) -> FlickrImageModel? {

        guard let title = entry[Constants.title].text else {
            LOG.error(Failed.toParse + Constants.title)
            return nil
        }
        
        let imageLinks = entry[Constants.link].filter { $0.attributes[Constants.rel] == Constants.enclosure }
        guard let imageLink = imageLinks.first else {
            LOG.error(Failed.toParse + Constants.link)
            return nil
        }
        
        guard let imageUrl = imageLink.attributes[Constants.href] else {
            LOG.error(Failed.toParse + Constants.href)
            return nil
        }
        
        let tags = entry[Constants.category].filter { $0.attributes[Constants.scheme] == Constants.tagsUrl }
        let tagsList = tags.map { $0.attributes[Constants.term]}.filter({ $0 != "" }) as! [String]
        
        let flickrImage = FlickrImageModel(title: title, imageUrl: imageUrl, tags: tagsList)
        
        guard let url = URL(string: imageUrl) else {
            LOG.error(Failed.toCreateURL + imageUrl)
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url as URL)
            flickrImage.image = UIImage(data: data as Data)
        } catch {
            LOG.error(Failed.getImageData)
        }
        
        return flickrImage
    }
    
    static func parseFlickrImageToModel(image: FlickrImage) -> FlickrImageModel? {
        
        let flickrImage = FlickrImageModel(title: image.title!, imageUrl: image.imageUrl!, tags: image.tags as! [String])
        flickrImage.image = UIImage(data: image.image as! Data)
        
        return flickrImage

    }
    
}
