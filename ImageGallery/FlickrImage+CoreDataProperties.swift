//
//  FlickrImage+CoreDataProperties.swift
//  
//
//  Created by Anum Qudsia on 02/08/2017.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FlickrImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlickrImage> {
        return NSFetchRequest<FlickrImage>(entityName: "FlickrImage");
    }

    @NSManaged public var title: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var image: NSData?
    @NSManaged public var tags: NSObject?

}
