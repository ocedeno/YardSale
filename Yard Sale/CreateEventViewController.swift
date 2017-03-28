//
//  CreateEventViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, SSRadioButtonControllerDelegate
{
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var useNewLocation: SSRadioButton!
    @IBOutlet weak var selectNewLocationButton: UIButton!
    @IBOutlet weak var useCurrentAddressButton: SSRadioButton!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var stopTimeField: UITextField!
    
    var radioButtonController: SSRadioButtonsController?
    let datePickerView: UIDatePicker = UIDatePicker()
    let timePickerView: UIDatePicker = UIDatePicker()

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
    }
    
    func saveEvent()
    {
        print("\nSaved Yard Sale Event")
    }
}
