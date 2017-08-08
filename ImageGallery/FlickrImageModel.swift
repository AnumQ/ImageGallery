//
//  FlickrImageModel.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation
import UIKit

class FlickrImageModel {
    
    var title: String
    var imageUrl: String
    var image: UIImage!
    var tags: [String]
    
    init(title: String, imageUrl: String, tags:[String]) {
        self.title = title
        self.imageUrl = imageUrl
        self.tags = tags
    }
}
