//
//  FlickrImage.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation
import UIKit

class FlickrImage {
    
    var title: String
    var imageUrl: String
    var image: UIImage!
    var tags: [String?]
    
    init(title: String, imageUrl: String, tags:[String?]) {
        self.title = title
        self.imageUrl = imageUrl
        self.tags = tags
    }
    
    func getImage(url: URL) {
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
}
