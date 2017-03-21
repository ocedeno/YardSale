//
//  SignUpViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/21/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController
{
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypedPasswordField: UITextField!
    
    @IBOutlet weak var addressField1: UITextField!
    @IBOutlet weak var addressField2: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addressUISetup(hidden: true)
    }
    @IBAction func returnToLogin()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useCurrentLocation(_ sender: UIButton)
    {
        if (sender.titleLabel?.text == "Yes")
        {
            addressUISetup(hidden: true)
        }else
        {
            addressUISetup(hidden: false)
        }
    }
    
    func addressUISetup(hidden: Bool)
    {
        addressField1.isHidden = hidden
        addressField2.isHidden = hidden
        stateField.isHidden = hidden
        zipCodeField.isHidden = hidden
    }
    
    @IBAction func createAccount()
    {
        
    }
}





