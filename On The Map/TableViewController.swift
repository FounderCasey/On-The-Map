//
//  TableViewController.swift
//  On The Map
//
//  Created by Casey Wilcox on 1/4/17.
//  Copyright © 2017 Casey Wilcox. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var studentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentTableView.delegate = self
        studentTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        studentTableView.reloadData()
    }
    
    @IBAction func refresh(_ sender: Any) {
        studentTableView.reloadData()
    }
    
    @IBAction func addPin(_ sender: Any) {
        let students = StudentModel.sharedInstance().getStudentInfo()
        let userObjectID = UdacityClient.sharedInstance().accountKey
        var userPresetLocation = String()
        var studentExists = false
        var studentObjectID = String()
        
        for student in students {
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
    
    func loadStudents() {
        self.activityIndicatorVisible(visible: true, view: self.view)
        StudentModel.sharedInstance().parseData(completionHandler: { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    self.activityIndicatorVisible(visible: false, view: self.view)
                    StudentModel.sharedInstance().getStudentInfo()
                } else if error != nil {
                    self.activityIndicatorVisible(visible: false, view: self.view)
                    self.alert(title: "Uh Oh", message: "Error downloading data")
                }
            }
        })
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
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.sharedInstance().getStudentInfo().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuse = "Cell"
        let student = StudentModel.sharedInstance().getStudentInfo()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuse, for: indexPath)
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = StudentModel.sharedInstance().getStudentInfo()[indexPath.row].mediaURL
        self.openURL(url: url)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
