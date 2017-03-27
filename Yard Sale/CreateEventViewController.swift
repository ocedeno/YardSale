//
//  CreateEventViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController
{
    @IBOutlet weak var useCurrentAddressButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Create Yard Sale"
        let saveButton = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveEvent))
        self.navigationItem.rightBarButtonItem = saveButton
        
        var radioButtonController = SSRadioButtonsController(buttons: useCurrentAddressButton)
        var currentButton = radioButtonController.selectedButton()
    }
    
    
    func saveEvent()
    {
        print("\nSaved Yard Sale Event")
    }
}
