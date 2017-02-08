//
//  UdacityClient.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/5/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    let session = URLSession.shared
    var accountKey = String()
    
    private override init() {}
    
    func getUserData(userID: String, completionHandler: @escaping (_ firstname: String?, _ lastname: String?, _ error: String?) -> Void) {
        let url = URL(string: Constants.udacityURL.getURL+userID)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                print("Error in Task - User Data")
                completionHandler(nil, nil, "No connection")
                return
            }
            
            guard let data = data else {
                completionHandler(nil, nil, "Data Error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, nil, "Connection problem")
                return
            }
            
            let newData = data.subdata(in: 5..<data.count);
            
            self.convertData(data: newData, completionHandler: {(result, error) in
                guard error == nil else {
                    completionHandler(nil, nil, "JSON Error - USER")
                    return
                }
                
                guard let result = result else {
                    completionHandler(nil, nil, "Result Error")
                    return
                }
                
                guard let user = result["user"] as? [String:AnyObject] else {
                    completionHandler(nil, nil, "User Error")
                    return
                }
                
                guard let firstName = user[Constants.udacityKeys.firstName] as? String else {
                    completionHandler(nil, nil, "Error with first")
                    return
                }
                
                guard let lastName = user[Constants.udacityKeys.lastName] as? String else {
                    completionHandler(nil, nil, "Error with last")
                    return
                }
                
                completionHandler(firstName, lastName, nil)
            })
        }
        task.resume()
    }
    
    func postSessionID(email: String, password: String, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.udacityURL.postURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                print("Error in Task - Session")
                completionHandler(false, "Connection Error")
                return
            }
            
            guard let data = data else {
                completionHandler(false, "Data Error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                if (statusCode == 400 || statusCode == 403) {
                    completionHandler(false, "Email or password is incorrect")
                    return
                } else {
                    completionHandler(false, "No connection")
                    return
                }
            }
            
            let newData = data.subdata(in: 5..<data.count);
            
            self.convertData(data: newData, completionHandler: { (result, error) in
                guard error == nil else {
                    completionHandler(false, "JSON Error")
                    return
                }
                
                guard let result = result else {
                    completionHandler(false, "Result Error")
                    return
                }
                
                guard let account = result[Constants.udacityKeys.account] as? [String:AnyObject] else {
                    completionHandler(false, "Account Error")
                    return
                }
                
                guard let key = account[Constants.udacityKeys.key] as? String else {
                    completionHandler(false, "Key Error")
                    return
                }
                
                self.accountKey = key
                completionHandler(true, nil)
            })
        }
        task.resume()
    }
    
    func deleteSession(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: Constants.udacityURL.postURL)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else {
                completionHandler(false, "Error in Task - Delete")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "No Connectoin")
                return
            }
            
            guard data != nil else {
                completionHandler(false, "Data Error")
                return
            }
            
            completionHandler(true, nil)
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
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
