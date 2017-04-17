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
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class LoginViewController: UIViewController
{
    @IBOutlet weak var fbButtonPlaceholder: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var userEmailTextfield: UITextField!
    @IBOutlet weak var userPasswordTextfield: UITextField!
    
    let utilityClass = Utility()
    let loginManager = FBSDKLoginManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createGoogleSignin()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
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

extension LoginViewController
{
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if (error != nil) || (result?.isCancelled)!
            {
                return print("Failed to login: \(String(describing: error?.localizedDescription))")
            }
            
            guard let accessToken = FBSDKAccessToken.current() else
            {
                return print("Failed to get access token")
            }
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                self.createUserAccount(name: (user?.displayName!)!)
            })
            
        }   
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        loginManager.logOut()
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            FBSDKLoginManager().logOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?)
    {
        guard error == nil else
        {
            return self.utilityClass.errorAlert(title: "Login Error", message: error!.localizedDescription, cancelTitle: "Dismiss", view: self)
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            guard error == nil else { return }
            self.createUserAccount(name: (user?.displayName!)!)
        }
    }
    
    func createGoogleSignin()
    {
        googleLoginButton.setImage(UIImage(named: "google_logo"), for: .normal)
        googleLoginButton.imageView?.contentMode = .scaleAspectFit
        googleLoginButton.addTarget(self, action: #selector(btnSignInPressed), for: UIControlEvents.touchUpInside)
    }
    
    func btnSignInPressed()
    {
        GIDSignIn.sharedInstance().signIn()
    }
}
