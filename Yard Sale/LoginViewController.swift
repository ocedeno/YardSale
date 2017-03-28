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
    
    let utilityClass = Utiliy()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil
            {
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVC")
                self.present(mainVC!, animated: true)
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
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion:
            {(user, error) in
                
                guard error == nil else
                {
                    self.utilityClass.errorAlert(title: "Signup Error", message: (error?.localizedDescription)!, cancelTitle: "Try Again", view: self)
                    
                    return
                }
                
                FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!)
                _ = User(authData: FIRAuth.auth()!.currentUser!, firstName: "john", lastName: "sanders")
               
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
            textEmail.keyboardType = .emailAddress
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
        FIRAuth.auth()?.signIn(withEmail: userEmailTextfield.text!, password: userPasswordTextfield.text!, completion: { (user, error) in
            
            guard error == nil else
            {
                self.utilityClass.errorAlert(title: "Login Error", message: (error?.localizedDescription)!, cancelTitle: "Try Again", view: self)
                
                return
            }
        })
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
