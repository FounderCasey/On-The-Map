//
//  LoginViewController.swift
//  On The Map
//
//  Created by Casey Wilcox on 11/3/16.
//  Copyright © 2016 Casey Wilcox. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    @IBAction func login(_ sender: Any) {
        self.resignFirstResponder()
        activityIndicatorVisible(visible: true, view: self.view)
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            alert(title: "Whoah!", message: "Don't be blank! Add some characters!")
        } else {
            if let email = emailTextField.text, let password = passwordTextField.text {
                UdacityClient.sharedInstance().postSessionID(email: email, password: password) { (success, error) in
                    performUIUpdatesOnMain {
                        if success {
                            self.loggedIn()
                            self.activityIndicatorVisible(visible: false, view: self.view)
                        } else if let error = error {
                            self.activityIndicatorVisible(visible: false, view: self.view)
                            self.alert(title: "Oops...", message: error)
                            
                        }
                    }
                }
            }
        }
    }
    
    func loggedIn() {
        performUIUpdatesOnMain {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "tabView") as! UITabBarController
            self.present(controller, animated: true)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        if let signUpURL = URL(string: Constants.udacityURL.signUpURL) {
            UIApplication.shared.open(signUpURL, options: [:], completionHandler: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

extension UIViewController {
    func alert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openURL(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.alert(title: "Oops", message: "Failed to open url")
        }
    }
    
    func activityIndicatorVisible(visible: Bool, view: UIView) {
        if visible {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            let container: UIView = UIView()
            let loadingView: UIView = UIView()
            container.tag = 1
            container.frame = view.frame
            container.center = view.center
            container.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.2)
            loadingView.frame = CGRect(x:0, y:0, width:65, height:65)
            loadingView.center = view.center
            loadingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.5)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            activityIndicator.frame = CGRect(x:0, y:0, width:35, height:35)
            activityIndicator.center = CGPoint(x: (loadingView.frame.size.width / 2), y: (loadingView.frame.size.height / 2))
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.color = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            performUIUpdatesOnMain {
                loadingView.addSubview(activityIndicator)
                container.addSubview(loadingView)
                view.addSubview(container)
                activityIndicator.startAnimating()
            }
        } else {
            let subViews = view.subviews
            for subview in subViews{
                if subview.tag == 1 {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}
