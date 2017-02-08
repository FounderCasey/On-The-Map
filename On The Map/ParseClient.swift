//
//  ParseClient.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/6/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import Foundation
import UIKit

class ParseClient: NSObject {
    let session = URLSession.shared
    
    private override init() {}
    
    func getParsedLocations(completionHandler: @escaping (_ location: [[String: AnyObject]]?, _ error: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.parseURL.limitedLocationsURL)!)
        request.addValue(Constants.parseURL.idKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.parseURL.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                completionHandler(nil, "Connection Error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, "No Connection")
                return
            }
            
            guard let data = data else {
                completionHandler(nil, "Data Error")
                return
            }
            
            self.convertData(data: data, completionHandler: { (result, error) in
                guard error == nil else {
                    completionHandler(nil, "JSON Error - GET")
                    return
                }
                
                guard let result = result else {
                    completionHandler(nil, "Result Error")
                    return
                }
                
                guard let locations = result["results"] as? [[String: AnyObject]] else {
                    completionHandler(nil, "Locations Error")
                    return
                }
                completionHandler(locations, nil)
            })
        }
        task.resume()
    }
    
    func updateStudentLocations(student: Student, httpMethod: String, objectID: String?, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        var urlString =  String()
        
        if httpMethod == Constants.HTTPMethods.put {
            if let objectID = objectID {
                urlString = "\(Constants.parseURL.locationsURL)/\(objectID))"
            }
        } else {
            urlString = Constants.parseURL.locationsURL
        }
        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod
        request.addValue(Constants.parseURL.idKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.parseURL.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(false, "Connection Error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "No Connection")
                return
            }
            
            guard let data = data else {
                completionHandler(false, "Data Error")
                return
            }
            
            self.convertData(data: data, completionHandler: { (result, error) in
                guard error == nil else {
                    completionHandler(false, "JSON Error - UPDATE")
                    return
                }
                
                guard let result = result else {
                    completionHandler(false, "Result Error")
                    return
                }
                
                guard (result[Constants.parseKeys.createdAt] as? String) != nil || (result[Constants.parseKeys.updatedAt] as? String) != nil else {
                    completionHandler(false, "Parsing Error")
                    return
                }
                completionHandler(true, nil)
            })
        }
        task.resume()
    }
    
    private func convertData(data: Data, completionHandler:(_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject? = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let user = [NSLocalizedDescriptionKey: "Failed to parse data"]
            completionHandler(nil, NSError(domain: "convertData", code: 1, userInfo: user))
        }
        completionHandler(parsedResult, nil)
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}
