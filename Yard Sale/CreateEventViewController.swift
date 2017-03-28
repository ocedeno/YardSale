//
//  CreateEventViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase

class CreateEventViewController: UIViewController, SSRadioButtonControllerDelegate
{
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var useNewLocation: SSRadioButton!
    @IBOutlet weak var selectNewLocationButton: UIButton!
    @IBOutlet weak var useCurrentAddressButton: SSRadioButton!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var stopTimeField: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    var radioButtonController: SSRadioButtonsController?
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    let utility = Utiliy()
    
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
    
    func didSelectButton(_ aButton: UIButton?)
    {
        if aButton == useCurrentAddressButton
        {
            print("Works")
            selectNewLocationButton.isHidden = true
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
    
    func startTimePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        startTimeField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func stopTimeTextFieldEditing(_ sender: UITextField)
    {
        let timePickerView: UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .time
        sender.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(stopTimePickerValueChanged), for: .valueChanged)
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
    
    func saveEvent()
    {
        guardCheck()
        dismissPicker()
        let dic = updateEvent()
        let userID = FIRAuth.auth()?.currentUser?.uid
        let event = Event(withTitle: dic["title"] as! String, onDate: dic["date"] as! String, atTime: dic["time"] as! String, withDescription: dic["description"] as! String, activeEvent: true)
        let taskFirebasePath = self.ref.ref.child("users").child(userID!.lowercased()).child("events")
        taskFirebasePath.setValue(event.toDictionary())
    }
    
    func updateEvent() -> [String: AnyObject]
    {
        let dic =
            [
                "title" : titleTextField.text! as AnyObject,
                "date" : dateTextField.text! as AnyObject,
                "time" : "\(startTimeField.text!) - \(stopTimeField.text!)" as AnyObject,
                "description" : descriptionText.text as AnyObject
        ]
        
        return dic
    }
    
    fileprivate func guardCheck()
    {
        let originalBorderColor = UIColor.init(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        guard !(titleTextField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: titleTextField)
            return
        }
        
        titleTextField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(dateTextField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: dateTextField)
            return
        }
        
        dateTextField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(startTimeField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: startTimeField)
            return
        }
        
        startTimeField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(stopTimeField.text!.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: stopTimeField)
            return
        }
        
        stopTimeField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(descriptionText.text.isEmpty) else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withTextView: descriptionText)
            return
        }
        
        descriptionText.layer.borderColor = originalBorderColor.cgColor
    }
    
    func updateBorder(withFrame frame: UITextField)
    {
        let redBorderColor = UIColor.red
        frame.layer.borderColor = redBorderColor.cgColor
        frame.layer.borderWidth = 1.0
        frame.layer.cornerRadius = 5.0
    }
    
    func updateBorder(withTextView frame: UITextView)
    {
        let redBorderColor = UIColor.red
        
        frame.layer.borderColor = redBorderColor.cgColor
        frame.layer.borderWidth = 1.0
        frame.layer.cornerRadius = 5.0;
    }
}
