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
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var addressField1: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var currentAddressLabel: UILabel!
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .automotiveNavigation
        
        return _locationManager
    }()
    
    var hasLocation: Bool = false
    
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
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            getCoordinates()
        }else
        {
            addressUISetup(isHidden: false)
            hasLocation = false
            hideResponseButtons(true)
        }
    }
    
    func addressUISetup(isHidden: Bool)
    {
        addressField1.isHidden = isHidden
        cityField.isHidden = isHidden
        stateField.isHidden = isHidden
        currentAddressLabel.isHidden = isHidden
    }
    
    func hideResponseButtons(_ hidden: Bool)
    {
        yesButton.isHidden = hidden
        noButton.isHidden = hidden
        currentLocationLabel.isHidden = hidden
    }
    
    func getCoordinates()
    {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways
        {
            self.locationManager.startUpdatingLocation()
            self.locationManager.stopUpdatingLocation()
        }else
        {
            addressUISetup(isHidden: false)
            if checkAddressFields()
            {
                let address = "\(addressField1.text!), \(cityField.text!), \(stateField.text!)"
                forwardGeocoding(address: address)
                //add coordinates to the Database
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation])
    {
        let userLocation: CLLocation = didUpdateLocations[0]
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        print("*LOCATIONMANAGER* Lat: \(lat) and Lon:\(lon)")
        //add coordinates to the Database
        hasLocation = true
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
        
        guard cityField.text != "" else
        {
            let alertController = UIAlertController(title: "Missing Info", message: "Please enter your city.", preferredStyle: .alert)
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
        
        return true
    }
    
    func forwardGeocoding(address: String)
    {
        CLGeocoder().geocodeAddressString(address) { (placemarks: [CLPlacemark]?,error: Error?) in
            guard error == nil else
            {
                DispatchQueue.main.async
                {
                    let alertController = UIAlertController(title: "Address Error", message: "Address information provided did not return a location. Try again.", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                        self.hasLocation = false
                }
                
                return
            }
            
            if (placemarks?.count)! > 0
            {
                DispatchQueue.main.async
                {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    print("*FORWARDGEO* lat: \(coordinate!.latitude), lon: \(coordinate!.longitude)")
                }
            }else
            {
                print("No Placemarks")
            }
        }
    }
    
    @IBAction func createAccount()
    {
        if (hasLocation)
        {
           print("Success through Current Location")
        }else
        {
            getCoordinates()
            print("Success through Address Manual")
        }
    }
}





