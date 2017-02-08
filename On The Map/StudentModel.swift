//
//  StudentModel.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/6/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentModel {
    private var objectID = String()
    private var studentInfo = [Student]()
    private var studentAnnotations = [MKPointAnnotation]()
    
    private init() {}
    
    func parseData(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        ParseClient.sharedInstance().getParsedLocations { (locations, error) in
            guard error == nil else {
                completionHandler(false, "Parse Error")
                return
            }
            
            guard let locations = locations else {
                completionHandler(false, "Locations Error")
                return
            }
            
            self.studentInfo = Student.parseResultsFromDownload(locations: locations)
            self.studentAnnotations = Student.createAnnotationsFrom(StudentArray: self.studentInfo)
            completionHandler(true, nil)
        }
    }
    
    func getStudentInfo() -> [Student] {
        return studentInfo
    }
    
    func getStudentAnnotations() -> [MKPointAnnotation] {
        return studentAnnotations
    }
    
    class func sharedInstance() -> StudentModel {
        struct Singleton {
            static var sharedInstance = StudentModel()
        }
        return Singleton.sharedInstance
    }
}
