//
//  ViewController.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class ViewController: UIViewController {

    var flickrImages: [FlickrImage]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

