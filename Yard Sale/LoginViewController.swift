//
//  LoginViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/21/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController
{

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var userEmailTextfield: UITextField!
    @IBOutlet weak var userPasswordTextfield: UITextField!
    
    let utilityClass = Utility()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil
            {
                let navVC = self.storyboard?.instantiateViewController(withIdentifier: "NavController")
                self.present(navVC!, animated: true)
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpAction()
    {
        let alert = UIAlertController(title: "Register",
                                      message: "Please enter your information below to create a new account.",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default)
        {action in
            let nameField = alert.textFields![0]
            let emailField = alert.textFields![1]
            let passwordField = alert.textFields![2]
            
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion:
            {(user, error) in
                
                guard error == nil else
                {
                    self.utilityClass.errorAlert(title: "Signup Error", message: (error?.localizedDescription)!, cancelTitle: "Try Again", view: self)
                    
                    return
                }
                
                LocationManager.sharedInstance.startUpdatingLocation()
                FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                    
                    guard error == nil else
                    {
                        DispatchQueue.main.async
                        {
                            self.utilityClass.errorAlert(title: "Email Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                        }
                        return
                    }
                })
                FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!)
                self.createUserAccount(name: nameField.text!)
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textName in
            textName.placeholder = "Enter your name"
            textName.autocapitalizationType = .words
        }
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
            textEmail.keyboardType = .emailAddress
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createUserAccount(name:String)
    {
        let ref: FIRDatabaseReference = FIRDatabase.database().reference()
        let authData = FIRAuth.auth()?.currentUser
        let delimiter = " "
        let token = name.components(separatedBy: delimiter)
        let firstName = token.first
        let lastName = token.last
        let user = User(authData: authData!, firstName: firstName!, lastName: lastName!)
        ref.ref.child("users").child((authData?.uid)!).setValue(user.toDictionary())
    }
    
    @IBAction func loginAction()
    {
        FIRAuth.auth()?.signIn(withEmail: userEmailTextfield.text!, password: userPasswordTextfield.text!, completion: { (user, error) in
            
            guard error == nil else
            {
                self.utilityClass.errorAlert(title: "Login Error", message: (error?.localizedDescription)!, cancelTitle: "Try Again", view: self)
                
                return
            }
        })
    }
    @IBAction func forgetPasswordAction()
    {
        let alert = UIAlertController(title: "Request New Password?", message: "If you forgot your password and would like to request a new one, please provide your email address below and instructions will be emailed to you.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        let send = UIAlertAction(title: "Send Request", style: .default) { action in
            let emailField = alert.textFields![0]
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailField.text!, completion: { (error) in
                guard error == nil else
                {
                    DispatchQueue.main.async
                        {
                            self.utilityClass.errorAlert(title: "Password Request", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                    }
                    return
                }
            })
        }
        alert.addTextField { (email) in
            email.placeholder = "Enter your email"
            email.keyboardType = .emailAddress
        }
        
        alert.addAction(cancel)
        alert.addAction(send)
        
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userEmailTextfield {
            userPasswordTextfield.becomeFirstResponder()
        }
        if textField == userPasswordTextfield {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
