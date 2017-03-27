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
    @IBOutlet weak var useCurrentAddressButton: UIButton!
    
    var radioButtonController: SSRadioButtonsController?
    var buttonIsSelected = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Create Yard Sale"
        let saveButton = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveEvent))
        self.navigationItem.rightBarButtonItem = saveButton
        
        radioButtonController = SSRadioButtonsController(buttons: useCurrentAddressButton)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
    }
    
    func didSelectButton(_ aButton: UIButton?)
    {
        buttonIsSelected = !buttonIsSelected
        let button = useCurrentAddressButton!
        if buttonIsSelected
        {
            button.setTitle("Using Stored Address", for: .normal)
        }else
        {
            button.setTitle("Use Stored Address?", for: .normal)
        }
    }
    
    func saveEvent()
    {
        print("\nSaved Yard Sale Event")
    }
}
