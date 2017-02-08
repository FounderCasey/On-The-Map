//
//  Student.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/5/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import Foundation
import MapKit

struct Student {
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
    var firstName: String
    var lastName: String
    var mediaURL: String
    var mapString: String?
    var uniqueKey: String
    var objectID: String?
    
    init(firstName: String, lastName: String, mediaURL: String, mapString: String, uniqueKey: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
        self.mapString = mapString
        self.uniqueKey = uniqueKey
        self.lat = latitude
        self.long = longitude
    }
    
    init?(dict: [String:AnyObject]) {
        
       guard let objectID = dict[Constants.parseKeys.objectID] as? String,
            let uniqueKey = dict[Constants.parseKeys.uniqueKey] as? String,
            let firstName = dict[Constants.parseKeys.firstName] as? String,
            let lastName = dict[Constants.parseKeys.lastName] as? String,
            let mapString = dict[Constants.parseKeys.mapString] as? String,
            let mediaURL = dict[Constants.parseKeys.mediaURL] as? String,
            let lat = dict[Constants.parseKeys.lat] as? Double,
            let long = dict[Constants.parseKeys.long] as? Double else {
                return nil
        }
        
        self.lat = CLLocationDegrees(lat)
        self.long = CLLocationDegrees(long)
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.uniqueKey = uniqueKey
        self.objectID = objectID
    }
    
    static func parseResultsFromDownload(locations: [[String: AnyObject]]) -> [Student] {
        var arrayOfStudents = [Student]()
        var errorCount = 0
        
        for location in locations {
            if let student = Student(dict: location){
                arrayOfStudents.append(student)
            }else{
                errorCount += 1
            }
        }
        print("error parsing \(errorCount) students")
        return arrayOfStudents
    }
    
    static func createAnnotationsFrom(StudentArray: [Student])-> [MKPointAnnotation]{
        var arrayOfAnnonations = [MKPointAnnotation]()
        
        for student in StudentArray{
            let coordinate = CLLocationCoordinate2D(latitude: student.lat, longitude: student.long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            arrayOfAnnonations.append(annotation)
        }
        return arrayOfAnnonations
    }
}
