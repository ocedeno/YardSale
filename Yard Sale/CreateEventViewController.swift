//
//  CreateEventViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CreateEventViewController: UIViewController, SSRadioButtonControllerDelegate
{
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var useNewLocation: SSRadioButton!
    @IBOutlet weak var useCurrentAddressButton: SSRadioButton!
    @IBOutlet weak var selectNewLocationButton: UIButton!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var stopTimeField: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var displayEvent: UISwitch!
    
    var radioButtonController: SSRadioButtonsController?
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    let utility = Utiliy()
    var locationManager: CLLocationManager!
    var locLat: Double?
    var locLon: Double?
    var addDictionary: [String:AnyObject]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Create Yard Sale"
        let saveButton = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveEvent))
        self.navigationItem.rightBarButtonItem = saveButton
        
        radioButtonController = SSRadioButtonsController(buttons: useCurrentAddressButton, useNewLocation)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        selectNewLocationButton.isHidden = true
    }
    
    internal func didSelectButton(_ aButton: UIButton?)
    {
        if aButton == useCurrentAddressButton
        {
            if CLLocationManager.locationServicesEnabled()
            {
                selectNewLocationButton.isHidden = true
                determineCurrentLocation()
            }else
            {
                selectNewLocationButton.isHidden = true
                utility.errorAlert(title: "Location Error", message: "We are not currently using your current location. Please accept our request to use your location for a smoother performance.", cancelTitle: "Okay", view: self)
                locationManager.requestAlwaysAuthorization()
            }
        }else
        {
            selectNewLocationButton.isHidden = false
        }
    }
    
    @IBAction func dateTextFieldEditing(_ sender: UITextField)
    {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @IBAction func startTimeTextFieldEditing(_ sender: UITextField)
    {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .time
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(startTimePickerValueChanged), for: .valueChanged)
    }
    
    @IBAction func stopTimeTextFieldEditing(_ sender: UITextField)
    {
        let timePickerView: UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .time
        sender.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(stopTimePickerValueChanged), for: .valueChanged)
    }
    
    func startTimePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        startTimeField.text = dateFormatter.string(from: sender.date)
    }
    
    func stopTimePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        stopTimeField.text = dateFormatter.string(from: sender.date)
    }
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func dismissPicker()
    {
        startTimeField.endEditing(true)
        stopTimeField.endEditing(true)
        dateTextField.endEditing(true)
        titleTextField.endEditing(true)
        descriptionText.endEditing(true)
    }
    
    func getCity(withCoordinates lat: Double, lon: Double)
    {
        let location: CLLocation = CLLocation(latitude: lat , longitude: lon)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            guard error == nil else
            {
                self.utility.errorAlert(title: "Location Error", message: "We could not retrieve a proper location based off the postion selected. Please try again.", cancelTitle: "Dismiss", view: self)
                return
            }
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if placeMark != nil
            {
                self.addDictionary = placeMark.addressDictionary! as? [String : AnyObject]
            }else
            {
                self.utility.errorAlert(title: "Location Error", message: "There was no placemarker near your pin. Please try again.", cancelTitle: "Try Again", view: self)
            }
        })
    }
    
    func saveEvent()
    {
        if guardCheck()
        {
            dismissPicker()
            let dic = updateEvent()
            let userID = FIRAuth.auth()?.currentUser?.uid
            
            let event = Event(withTitle: dic["title"] as! String, onDate: dic["date"] as! String, startTime: dic["startTime"] as! String, stopTime: dic["stopTime"] as! String, withDescription: dic["description"] as! String, userID: userID! ,activeEvent: displayEvent.isOn, locationLatitude: dic["locLat"] as! Double, locationLongitude: dic["locLon"] as! Double, addDict: dic["addressDictionary"] as! [String:AnyObject])
            
            let taskFirebasePath = self.ref.ref.child("events").childByAutoId()
            taskFirebasePath.setValue(event.toDictionary())
        }
    }
    
    fileprivate func updateEvent() -> [String: AnyObject]
    {
        let dic =
            [
                "title" : titleTextField.text! as AnyObject,
                "date" : dateTextField.text! as AnyObject,
                "startTime" : startTimeField.text! as AnyObject,
                "stopTime" : stopTimeField.text! as AnyObject,
                "description" : descriptionText.text as AnyObject,
                "locLat" : locLat as AnyObject,
                "locLon" : locLon as AnyObject,
                "addressDictionary" : addDictionary!
        ] as [String : Any]
        
        return dic as [String : AnyObject]
    }
    
    fileprivate func guardCheck() -> Bool
    {
        let originalBorderColor = UIColor.init(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        guard !(titleTextField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: titleTextField)
            return false
        }
        
        titleTextField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(dateTextField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: dateTextField)
            return false
        }
        
        dateTextField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(startTimeField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: startTimeField)
            return false
        }
        
        startTimeField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(stopTimeField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: stopTimeField)
            return false
        }
        
        stopTimeField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(descriptionText.text.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withTextView: descriptionText)
            return false
        }
        
        descriptionText.layer.borderColor = originalBorderColor.cgColor
        return true
    }
    
    fileprivate func updateBorder(withFrame frame: UITextField)
    {
        let redBorderColor = UIColor.red
        frame.layer.borderColor = redBorderColor.cgColor
        frame.layer.borderWidth = 1.0
        frame.layer.cornerRadius = 5.0
    }
    
    fileprivate func updateBorder(withTextView frame: UITextView)
    {
        let redBorderColor = UIColor.red
        
        frame.layer.borderColor = redBorderColor.cgColor
        frame.layer.borderWidth = 1.0
        frame.layer.cornerRadius = 5.0;
    }
}

extension CreateEventViewController: CLLocationManagerDelegate
{
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentLocation: CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        locLon = currentLocation.coordinate.longitude
        locLat = currentLocation.coordinate.latitude
        getCity(withCoordinates: locLat!, lon: locLon!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        utility.errorAlert(title: "Map Error", message: error.localizedDescription, cancelTitle: "Dismiss", view: self)
    }
}
