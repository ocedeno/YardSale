//
//  UserProfileViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 4/3/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController
{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userEmailField: UITextField!
    @IBOutlet weak var userAddressField: UITextField!
    @IBOutlet weak var userCityField: UITextField!
    @IBOutlet weak var userStateField: UITextField!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userZipCodeField: UITextField!
    
    var userInfo: User?
    let utilityClass = Utility()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createReferenceToUser()
        setupProfileImageView()
        createUpdateBarButtonItem()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(gesture)
    }
    
    func createReferenceToUser()
    {
        let uniqueID = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("users")
        let userRefPath = ref.child(uniqueID!)
        userRefPath.observe(.value, with: { (snapshot) in
            
            self.userInfo = User(snapshot: snapshot)
            self.populateUserValues()
        })
    }
    
    func createUpdateBarButtonItem()
    {
        let updateButton = UIBarButtonItem.init(title: "Update", style: .plain, target: self, action: #selector(storeUserAddress))
        self.navigationItem.rightBarButtonItem = updateButton
    }
    
    func storeUserAddress()
    {
        let streetAddress = userAddressField.text!
        let cityAddress = userCityField.text!
        let stateAddress = userStateField.text!
        let zipCodeAddress = userZipCodeField.text!
        let userAddress = "\(streetAddress), \(cityAddress), \(stateAddress) \(zipCodeAddress)"
        print(userAddress)
    }
    
    func setupProfileImageView()
    {
        userProfileImageView.layer.borderWidth=1.0
        userProfileImageView.layer.masksToBounds = false
        userProfileImageView.layer.borderColor = UIColor.white.cgColor
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.height/2
        userProfileImageView.clipsToBounds = true
        userProfileImageView.image = UIImage.vintageWoodBackground()
    }
    
    func populateUserValues()
    {
        let firstName = userInfo?.firstName!
        let lastName = userInfo?.lastName!
        let fullName = "\(firstName!) \(lastName!)"
        userNameLabel.text = fullName
        userEmailField.text = userInfo?.email!
        userNameField.text = fullName
    }
    
    func dismissKeyboard()
    {
        userNameField.endEditing(true)
        userEmailField.endEditing(true)
        userAddressField.endEditing(true)
        userCityField.endEditing(true)
        userStateField.endEditing(true)
        userZipCodeField.endEditing(true)
    }
}
