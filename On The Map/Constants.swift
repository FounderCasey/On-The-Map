//
//  Constants.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/3/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import Foundation

class Constants {
    struct udacityURL{
        static let postURL = "https://www.udacity.com/api/session"
        static let getURL = "https://www.udacity.com/api/users/"
        static let signUpURL = "https://www.udacity.com/account/auth#!/signup"
    }
    
    struct udacityKeys{
        static let account = "account"
        static let key = "key"
        static let lastName = "last_name"
        static let firstName = "first_name"
    }
    
    struct parseURL{
        static let idKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let limitedLocationsURL = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt"
        static let locationsURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    }
    
    struct parseKeys{
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let results = "results"
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let lat = "latitude"
        static let long = "longitude"
        
    }
    
    struct HTTPMethods {
        static let post = "POST"
        static let put = "PUT"
    }
    
}
