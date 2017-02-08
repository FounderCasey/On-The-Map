//
//  MapViewController.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/4/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(StudentModel.sharedInstance().getStudentAnnotations())
    }
    
    @IBAction func refresh(_ sender: Any) {
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.loadAnnotations()
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        let userObjectID = UdacityClient.sharedInstance().accountKey
        var userPresetLocation = String()
        var studentExists = false
        var studentObjectID = String()
        
        for student in StudentModel.sharedInstance().getStudentInfo() {
            if student.uniqueKey == userObjectID {
                studentExists = true
                if let objectID = student.objectID, let userLocation = student.mapString {
                    userPresetLocation = userLocation
                    studentObjectID = objectID
                }
            }
        }
        
        if studentExists{
            let alert = UIAlertController(title: "Pin already exists", message: "Do you want to update information?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "CreatePin") as! CreatePinViewController
                controller.presetUserLocation = userPresetLocation
                controller.studentID = studentObjectID
                controller.sendingView = self
                controller.method = Constants.HTTPMethods.put
                self.present(controller, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
            
            
        } else {
            let controller = storyboard?.instantiateViewController(withIdentifier: "CreatePin") as! CreatePinViewController
            controller.studentID = userObjectID
            controller.method = Constants.HTTPMethods.post
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
        self.dismiss(animated: true) {
            UdacityClient.sharedInstance().deleteSession(completionHandler: { (success, error) in
                performUIUpdatesOnMain {
                    if success {
                        print("Logged Out")
                    } else if error != nil {
                        self.alert(title: "Uh Oh!", message: "Error logging out")
                    }
                }
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let url = view.annotation?.subtitle! {
                self.openURL(url: url)
            }
        }
    }
    
    func loadAnnotations() {
        self.activityIndicatorVisible(visible: true, view: self.view)
        StudentModel.sharedInstance().parseData { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    self.activityIndicatorVisible(visible: false, view: self.view)
                    self.mapView.addAnnotations(StudentModel.sharedInstance().getStudentAnnotations())
                } else if error != nil {
                    self.activityIndicatorVisible(visible: false, view: self.view)
                    self.alert(title: "Uh Oh", message: "Error downloading annotations")
                }
            }
        }
    }
}

















