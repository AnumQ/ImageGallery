//
//  Constants.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation

struct Constants {
    static let feed = "feed"
    static let entry = "entry"
    static let title = "title"
    static let link = "link"
    static let href = "href"
    static let rel = "rel"
    static let enclosure = "enclosure"
    static let category = "category"
    static let scheme = "scheme"
    static let tagsUrl = "https://www.flickr.com/photos/tags/"
    static let imageUrl = "imageUrl"
    static let tags = "tags"
    static let image = "image"
    static let term = "term"
}

struct Entity {
    static let FlickrImage = "FlickrImage"
}

struct Failed {
    static let getImageData = "Failed to get image data from url"
    static let saveImage = "Error saving flickrImage entity"
    static let fetchImages = "Failed to fetch images"
    static let deleteImages = "Failed to delete all images"
    static let toParse = "Failed to parse "
    static let toCreateURL = "Failed to create URL from "
}

struct Success {
    static let imageSaved = "Saved FlickrImage sucessfully"
}


