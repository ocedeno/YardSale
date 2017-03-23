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

    @IBOutlet weak var userEmailTextfield: UITextField!
    @IBOutlet weak var userPasswordTextfield: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpAction()
    {
        let alert = UIAlertController(title: "Register",
                                      message: "Please enter your information below to create a new account.",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default)
        {action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                
                guard error == nil else {
                    let alert = UIAlertController(title: "Sign-Up Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Try Again",
                                                     style: .default)
                    alert.addAction(cancelAction)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                    FIRAuth.auth()?.signIn(withEmail: self.userEmailTextfield.text!, password: self.userPasswordTextfield.text!)
                    print("\(user?.email!)")
               
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginAction()
    {
        
    }
}
