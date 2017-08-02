//
//  Parser.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class Parser {
    
    static func parseEntryToFlickrImage(entry: XML.Accessor) -> FlickrImage? {

        guard let title = entry[Constants.title].text else {
            LOG.error("Unable to parse \(Constants.title)")
            return nil
        }
        
        let imageLinks = entry[Constants.link].filter { $0.attributes[Constants.rel] == Constants.enclosure }
        guard let imageLink = imageLinks.first else {
            LOG.error("Unable to parse \(Constants.link)")
            return nil
        }
        
        guard let imageUrl = imageLink.attributes[Constants.href] else {
            LOG.error("Unable to parse \(Constants.href)")
            return nil
        }
        
        let tags = entry[Constants.category].filter { $0.attributes[Constants.scheme] == Constants.tagsUrl }
        let tagsList = tags.map { $0.attributes["term"]}.filter({ $0 != "" }) as! [String]
        
        let flickrImage = FlickrImage(title: title, imageUrl: imageUrl, tags: tagsList)
        
        guard let url = URL(string: imageUrl) else {
            LOG.error("Unable to create URL from \(imageUrl)")
            return nil
        }
        
        flickrImage.getImage(url: url)
        
        return flickrImage
    }
    
}
