//
//  CreatePinViewController.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/9/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import UIKit
import MapKit

class CreatePinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    var studentID: String? = nil
    var method: String!
    var presetUserLocation: String?
    var userLocation : CLLocationCoordinate2D?
    var mapString = String()
    var gotLocation = false
    var sendingView: UIViewController?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        if gotLocation == false {
            getGeocodedLocationFromUser { (success, error) in
                if success{
                    self.locationTextField.text = ""
                    self.locationTextField.placeholder = "Ex: https://udacity.com"
                    self.label.text = "Add your link."
                    self.confirmButton.setTitle("Confirm Link", for: UIControlState.normal)
                    self.gotLocation = true
                } else if error != nil {
                    self.alert(title: "Oops", message: "Cannot Find Location")
                }
            }
        }
        
        if gotLocation == true {
            self.activityIndicatorVisible(visible: true, view: self.view)
            submitLocation(completionHandler: { (success, error) in
                performUIUpdatesOnMain {
                    if success{
                        self.activityIndicatorVisible(visible: false, view: self.view)
                        self.dismiss(animated: true, completion: {
                            if self.method == Constants.HTTPMethods.post {
                                self.sendingView?.alert(title: "Success!", message: "Successfully created")
                            } else {
                                self.sendingView?.alert(title: "Success!", message: "Successfully edited")
                            }
                        })
                    } else {
                        if error != nil {
                            self.activityIndicatorVisible(visible: false, view: self.view)
                            self.alert(title: "Oops", message: (error)!)
                        }
                    }
                }
            })
        }
    }
    
    func getGeocodedLocationFromUser(completionHandler: @escaping (_ success : Bool, _ error: String?) -> Void) {
        if let locationText = locationTextField.text, locationText != "" {
            mapString = locationText
            self.activityIndicatorVisible(visible: true, view: self.view)
            CLGeocoder().geocodeAddressString(locationText, completionHandler: { (placemark, error) in
                self.processGeocodeResponse(withPlacemarks: placemark, error: error, coordCompletionHandler: { (success, error) in
                    guard error == nil else{
                        self.activityIndicatorVisible(visible: false, view: self.view)
                        completionHandler(false, "Enter valid location")
                        return
                    }
                    
                    guard let userLocation = self.userLocation else{
                        self.activityIndicatorVisible(visible: false, view: self.view)
                        completionHandler(false, "Enter valid location")
                        return
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = userLocation
                    self.mapView.addAnnotation(annotation)
                    let span = MKCoordinateSpanMake(0.015, 0.015)
                    let region = MKCoordinateRegionMake(userLocation, span)
                    self.mapView.setRegion(region, animated: true)
                    completionHandler(true, nil)
                    self.activityIndicatorVisible(visible: false, view: self.view)
                })
            })
        } else {
            completionHandler(false, "Textfield Empty")
        }
    }
    
    func submitLocation(completionHandler : @escaping (_ success: Bool, _ error : String?) -> Void){
        if let location = self.locationTextField.text, location != "", checkURL(urlString: location) == true {
            UdacityClient.sharedInstance().getUserData(userID: UdacityClient.sharedInstance().accountKey, completionHandler: { (firstName, lastName, error) in
                if let firstName = firstName, let lastName = lastName {
                    let student = Student(firstName: firstName, lastName: lastName, mediaURL: location , mapString: self.mapString, uniqueKey: UdacityClient.sharedInstance().accountKey, latitude: (self.userLocation?.latitude)!, longitude: (self.userLocation?.longitude)!)
                    
                    ParseClient.sharedInstance().updateStudentLocations(student: student, httpMethod: self.method, objectID: self.studentID, completionHandler: { (success, error) in
                        if success{
                            StudentModel.sharedInstance().parseData(completionHandler: { (success, error) in
                                if success{
                                    completionHandler(true, nil)
                                } else {
                                    completionHandler(false, "Error updating information")
                                }
                            })
                        } else {
                            completionHandler(false, "Error posting student information")
                        }
                    })
                } else {
                    print("Handle error \(error!)")
                    completionHandler(false, "Check network condition")
                }
            })
        } else {
            completionHandler(false, "Enter a valid URL")
        }
    }
    
    func processGeocodeResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?, coordCompletionHandler: (_ success: Bool, _ error: String?) -> Void) {
        guard error == nil else {
            coordCompletionHandler(false, "Location wasn't found")
            return
        }
        
        var location: CLLocation?
        
        if let placemarks = placemarks, placemarks.count > 0 {
            location = placemarks.first?.location
        }
        
        if let location = location {
            userLocation = location.coordinate
            coordCompletionHandler(true, nil)
            
        } else {
            coordCompletionHandler(false, "No location found")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = true
    }
    
    func checkURL(urlString: String) -> Bool {
        if let url = URL(string: urlString){
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}
