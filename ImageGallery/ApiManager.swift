//
//  ApiManager.swift
//  ImageGallery
//
//  Created by Anum Qudsia on 26/07/2017.
//  Copyright © 2017 anum.qudsia. All rights reserved.
//

import Foundation
import SwiftyXMLParser

typealias ServiceResponse = (XML.Accessor?, Int, Error?) -> Void

class ApiManager: NSObject, XMLParserDelegate {
    
    enum HTTPMethod: String {
        case GET, PUT, DELETE
    }
    
    static let sharedInstance = ApiManager()
    fileprivate let baseURL = "https://api.flickr.com/services/feeds/photos_public.gne"
    
    func fetchImages(onCompletion: @escaping (XML.Accessor?, Error?) -> Void) {
        
        let route = baseURL
       // let params = [Constants.apiKey: Config.sharedInstance.getAPIKey(), Constants.favorites: String(Constants.numberOfExpectedResults), Constants.resume: String(Constants.numberOfExpectedResults)]
        
        performRequest(route, params: [:], requestHttpMethod: HTTPMethod.GET.rawValue) { xml, statusCode, err in
            guard err == nil else { return onCompletion(nil, err) }
            guard statusCode == 200 else { return onCompletion(nil, NSError(domain: "Failed with responseCode " + String(statusCode), code: statusCode, userInfo: nil)) }
            onCompletion(xml, err)
        }
    }
    
    fileprivate func performRequest(_ path:String, params: [String: String], requestHttpMethod: String, onCompletion: @escaping ServiceResponse) {
        let request = createRequest(path, params: params)
        
        request.httpMethod = requestHttpMethod
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error -> Void in
            guard error == nil else {
               // LOG.debug("Error occured while sending request to PSAPI. More info: \(errorInfo)");
                return
            }
            
            let userInfo: [String: Any] = ["data": data as Any, "response": response as Any]
            guard let httpresponse = response as! HTTPURLResponse? else { return onCompletion(nil, 0, NSError(domain: "Error getting httpresponse", code: 0, userInfo: userInfo))}
            guard let xmlData = data else { return onCompletion(nil, httpresponse.statusCode, NSError(domain: "Error getting data", code: httpresponse.statusCode, userInfo: userInfo)) }
            
            let accessor = XML.parse(xmlData)
            
            onCompletion(accessor, httpresponse.statusCode, nil)
        }
        task.resume()
    }
    
    fileprivate func createRequest(_ path: String, params: [String: String]) -> NSMutableURLRequest {
        
        var urlComponents = URLComponents(string: path)
        
        let parameters = params
        urlComponents?.queryItems = []
        for parameter in parameters {
            urlComponents?.queryItems?.append(URLQueryItem(name: parameter.key, value: parameter.value))
        }
        
        let request = NSMutableURLRequest(url: urlComponents!.url!)
        return request
    }
    
}
