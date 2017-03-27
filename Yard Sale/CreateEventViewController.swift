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
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var useNewLocation: SSRadioButton!
    @IBOutlet weak var selectNewLocationButton: UIButton!
    @IBOutlet weak var useCurrentAddressButton: SSRadioButton!
    
    var radioButtonController: SSRadioButtonsController?
    let datePickerView: UIDatePicker = UIDatePicker()
    
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
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateTextField.text = dateFormatter.string(from: sender.date)
        
    }
    
    func dismissPicker()
    {
        datePickerView.removeFromSuperview()
        print("Tapped")
    }
    
    func saveEvent()
    {
        print("\nSaved Yard Sale Event")
    }
}
