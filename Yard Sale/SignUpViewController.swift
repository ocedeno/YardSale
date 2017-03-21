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
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var currentAddressLabel: UILabel!
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .automotiveNavigation
        
        return _locationManager
    }()
    var hasLocation: Bool?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addressUISetup(isHidden: true)
    }
    @IBAction func returnToLogin()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useCurrentLocation(_ sender: UIButton)
    {
        if (sender.titleLabel?.text == "Yes")
        {
            addressUISetup(isHidden: true)
            locationManager.requestWhenInUseAuthorization()
            getCoordinates()
        }else
        {
            addressUISetup(isHidden: false)
            hasLocation = false
        }
    }
    
    func addressUISetup(isHidden: Bool)
    {
        addressField1.isHidden = isHidden
        stateField.isHidden = isHidden
        zipCodeField.isHidden = isHidden
        currentAddressLabel.isHidden = isHidden
    }
    
    func getCoordinates()
    {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
        {
            self.locationManager.startUpdatingLocation()
            print("Services Enabled")
        }else
        {
            if checkAddressFields()
            {
                let address = "\(addressField1.text!), \(stateField.text!), \(zipCodeField.text!)"
                let userLocation = forwardGeocoding(address: address)
                print("User Location based off of Address: \(userLocation)")
                //add coordinates to the Database
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation])
    {
        let userLocation: CLLocation = didUpdateLocations[0]
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        print("Lat: \(lat) and Lon:\(lon)")
        //add coordinates to the Database
        hasLocation = true
        locationManager.stopUpdatingLocation()
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
    
    func forwardGeocoding(address: String) -> CLLocation
    {
        var clLocation: CLLocation?
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            
            guard error == nil else
            {
                DispatchQueue.main.async
                {
                    let alertController = UIAlertController(title: "Incorrect Address", message: "Address information provided did not return a location. Try again.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.hasLocation = false
                }
                
                return
            }
            
            if (placemarks?.count)! > 0
            {
                let placemark = placemarks?[0]
                let location = placemark?.location
                clLocation = location!
                let coordinate = location?.coordinate
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                
                if (placemark?.areasOfInterest?.count)! > 0
                {
                    let areaOfInterest = placemark!.areasOfInterest![0]
                    print("Areas of Interest: \(areaOfInterest)")
                }else
                {
                    print("No area of interest found.")
                }
            }
        })
        
        return clLocation!
    }
    
    @IBAction func createAccount()
    {
        if (hasLocation!)
        {
           print("Success")
        }else
        {
            getCoordinates()
            print("Success through Address Manual")
        }
    }
}





