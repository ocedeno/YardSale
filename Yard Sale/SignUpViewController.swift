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
import CoreLocation

class SignUpViewController: UIViewController, CLLocationManagerDelegate
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
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addressUISetup(hidden: true)
        locationManager.delegate = self
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
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
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





