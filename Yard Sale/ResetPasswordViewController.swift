//
//  ResetPasswordViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/21/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController
{

    @IBOutlet weak var userEmailTextfield: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    @IBAction func resetPasswordAction()
    {
        
    }
    
    @IBAction func returnToLogin()
    {
        dismiss(animated: true, completion: nil)
    }
}
