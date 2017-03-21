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
import AddressBookUI

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
    var hasLocation: Bool?
    
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
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled()
            {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                hasLocation = true
                //add coordinates to the Database
                //getCoordinates()
            }else{
                addressUISetup(hidden: false)
                hasLocation = false
            }
            
        }else
        {
            addressUISetup(hidden: false)
            hasLocation = false
        }
    }
    
    func addressUISetup(hidden: Bool)
    {
        addressField1.isHidden = hidden
        addressField2.isHidden = hidden
        stateField.isHidden = hidden
        zipCodeField.isHidden = hidden
    }
    
    func getCoordinates()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            func locationManager(manager: CLLocationManager, didUpdateLocations: [CLLocation])
            {
                let userLocation: CLLocation = didUpdateLocations[0]
                let lat = userLocation.coordinate.latitude
                let lon = userLocation.coordinate.longitude
                print("Lat: \(lat) and Lon:\(lon)")
            }
        }else{
            if checkAddressFields()
            {
                
            }
        }
    }
    
    func checkAddressFields() -> Bool
    {
        guard addressField1.text != "" else
        {
            let alertController = UIAlertController(title: "Missing Info", message: "Please enter your address.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
            return false
        }
        
        guard stateField.text != "" else
        {
            let alertController = UIAlertController(title: "Missing Info", message: "Please enter your state.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
            return false
        }
        
        guard zipCodeField.text != "" else
        {
            let alertController = UIAlertController(title: "Missing Info", message: "Please enter your zip code.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    @IBAction func createAccount()
    {
        //getCoordinates()
        if (hasLocation!)
        {
            
        }
    }
}





