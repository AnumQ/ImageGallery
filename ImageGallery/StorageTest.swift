//
//  StorageTest.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 02/08/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import XCTest
@testable import ImageGallery

class StorageTest: XCTestCase {
    
    func testStorageAddsImageFromModelToStorage() {
        
        let flickrImage = FlickrImageModel(title: "testImage", imageUrl: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Push_van_cat.jpg", tags: ["cat"])
        
        Storage.deleteAllImages()
        
        Storage.addImage(flickrImage: flickrImage)
        
        let images = Storage.getImages()
        
        XCTAssert(images != nil)
        XCTAssertTrue(images!.count == 1)
    }
    
    func testStorageDeletesAllImages() {
        
        let flickrImage = FlickrImageModel(title: "testImage", imageUrl: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Push_van_cat.jpg", tags: ["cat"])
        
        Storage.addImage(flickrImage: flickrImage)
        
        Storage.deleteAllImages()
        
        let images = Storage.getImages()
        
        XCTAssert(images != nil)
        XCTAssertTrue(images!.count == 0)
    }
    
    func testStorageAddsCorrectDataFromModel() {
        let title = "testImage"
        let imageUrl = "https://upload.wikimedia.org/wikipedia/commons/4/4c/Push_van_cat.jpg"
        let tags = ["cat"]
        let flickrImage = FlickrImageModel(title: title, imageUrl: imageUrl, tags: tags)
        
        Storage.deleteAllImages()
        Storage.addImage(flickrImage: flickrImage)
        
        let images = Storage.getImages()
        XCTAssert(images != nil)
        
        XCTAssertTrue(images?[0].title == title)
        XCTAssertTrue(images?[0].imageUrl == imageUrl)
        XCTAssertTrue(images?[0].tags as! [String] == tags)
        
        let imageURL = URL(string: flickrImage.imageUrl)
        
        do {
            let data = try Data(contentsOf: imageURL! as URL)
            XCTAssert(images?[0].image as! Data == data)
        } catch {
            XCTFail("Test failed - Unable to get data from url")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
