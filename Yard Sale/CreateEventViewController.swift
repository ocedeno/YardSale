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
    @IBOutlet weak var useNewLocation: SSRadioButton!
    @IBOutlet weak var selectNewLocationButton: UIButton!
    @IBOutlet weak var useCurrentAddressButton: SSRadioButton!
    
    var radioButtonController: SSRadioButtonsController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Create Yard Sale"
        let saveButton = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveEvent))
        self.navigationItem.rightBarButtonItem = saveButton
        
        radioButtonController = SSRadioButtonsController(buttons: useCurrentAddressButton, useNewLocation)
        radioButtonController?.setButtonsArray([useCurrentAddressButton, useNewLocation])
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = false
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
    
    func saveEvent()
    {
        print("\nSaved Yard Sale Event")
    }
}
