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
    let datePickerView: UIDatePicker = UIDatePicker()
    let timePickerView: UIDatePicker = UIDatePicker()
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
        datePickerView.datePickerMode = .date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    @IBAction func startTimeTextFieldEditing(_ sender: UITextField)
    {
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
        let userID = FIRAuth.auth()?.currentUser?.uid
        let eventRef = ref.child("users").child(userID!).child("events")
        print("\nSaved Yard Sale Event \n\(updateEvent(withTitle: titleTextField, descript: descriptionText, date: dateTextField, startTime: startTimeField, stopTime: stopTimeField))")
    }
    
    func updateEvent(withTitle: UITextField, descript: UITextView, date: UITextField, startTime: UITextField, stopTime: UITextField) -> [String: AnyObject]
    {
        guardCheck(withTitle: withTitle, descript: descript, date: date, startTime: startTime, stopTime: stopTime)
        
        let dic =
        [
            "title" : withTitle.text! as AnyObject,
            "date" : date.text! as AnyObject,
            "time" : "\(startTime.text!) - \(stopTime.text!)" as AnyObject,
            "description" : descript.text as AnyObject
        ]
        
        return dic
    }
    
    fileprivate func guardCheck(withTitle: UITextField, descript: UITextView, date: UITextField, startTime: UITextField, stopTime: UITextField)
    {
        guard !(withTitle.text?.isEmpty)! || !(date.text?.isEmpty)! || !(startTime.text?.isEmpty)! || !(stopTime.text?.isEmpty)! || !(descript.text?.isEmpty)! else
        {
            utility.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            
            updateBorder(withFrame: titleTextField)
            updateBorder(withFrame: dateTextField)
            updateBorder(withFrame: startTime)
            updateBorder(withFrame: stopTime)
            updateBorder(withTextView: descriptionText)
        
            return
        }
    }
    
    func updateBorder(withFrame frame: UITextField)
    {
        let originalBorderColor = UIColor.init(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        let redBorderColor = UIColor.red
        
        if frame.text!.isEmpty
        {
            frame.layer.borderColor = redBorderColor.cgColor
            frame.layer.borderWidth = 1.0
        }else
        {
            frame.layer.borderColor = originalBorderColor.cgColor
            frame.layer.borderWidth = 1.0
        }
    }
    
    func updateBorder(withTextView frame: UITextView)
    {
        let originalBorderColor = UIColor.init(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        let redBorderColor = UIColor.red
        
        if frame.text!.isEmpty
        {
            frame.layer.borderColor = redBorderColor.cgColor
            frame.layer.borderWidth = 1.0
        }else
        {
            frame.layer.borderColor = originalBorderColor.cgColor
            frame.layer.borderWidth = 1.0
        }
    }
}
