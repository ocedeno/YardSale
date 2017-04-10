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
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userInfo: User?
    let utilityClass = Utility()
    var firUser = FIRAuth.auth()?.currentUser
    var ref: FIRDatabaseReference? = nil
    var imageDataArray: [Data] = []
    var imageRefArray: [String] = []
    var userEvent: Event?
    var userEventArray: [Event]?
    var uniqueID: String?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createReferenceToUser()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(gesture)
        collectionView.dataSource = self
        collectionView.delegate = self
        setupProfileImageView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        utilityClass.createBackgroundImageView(view: self.view)
        createUpdateBarButtonItem()
        collectionView.backgroundColor = UIColor.clear
        imagePicker.delegate = self
    }
    
    func createReferenceToUser()
    {
        print("\n1-CreateRef")
        let uniqueID = firUser?.uid
        let ref = FIRDatabase.database().reference().child("users")
        let userRefPath = ref.child(uniqueID!)
        userRefPath.observe(.value, with: { (snapshot) in
            
            self.userInfo = User(snapshot: snapshot)
            self.populateUserValues()
            self.populateUserAddress()
            self.getUserEventImageRef()
        })
    }
    
    func getUserEventImageRef()
    {
        print("\n2-GetUserEventImageRef")
        let eventRef = FIRDatabase.database().reference().child("users").child((firUser?.uid)!).child("events").child("event")
        eventRef.observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as! String
            print("\nValue : \(value)")
            self.imageRefArray.append(value)
            self.getUserEvent()
        })
    }
    
    func getUserEvent()
    {
        print("\n3-GetUserEvent")
        let eventRef = FIRDatabase.database().reference().child("events")
        for imageRef in imageRefArray
        {
            eventRef.child(imageRef).observe(.value, with: { (snapshot) in
                self.uniqueID = imageRef
                print("\nUniqueID: \(self.uniqueID!)")
                self.userEvent = Event(snapshot: snapshot)
                self.userEventArray?.append(self.userEvent!)
                self.populateDataArray()
            })
        }
    }
    
    func createImageStorageReference() -> FIRStorageReference
    {
        print("\n4-CreateImageStorageRef")
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        let eventImageRef = imageRef.child(uniqueID!)
        print("\nEventImageRef: \(eventImageRef)")
        
        return eventImageRef
    }
    
    func createProfileImageStorageReference() -> FIRStorageReference
    {
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("userProfile")
        let profileImageRef = imageRef.child((firUser?.uid)!)
        
        return profileImageRef
    }
    
    func populateDataArray()
    {
        let eventImageRef = createImageStorageReference()
        print("\n5-populateDataArray")
        guard userEvent?.imageTitleDictionary != nil else
        {
            print("\nNo images from User.")
            return
        }
        
        for item in (userEvent?.imageTitleDictionary)!
        {
            print("\nItem from imageTitleDict: \(item)")
            eventImageRef.child(item.value).data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                
                guard error == nil else
                {
                    DispatchQueue.main.async
                        {
                            self.utilityClass.errorAlert(title: "Event Image Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                            print("\n\(error.debugDescription)")
                    }
                    return
                }
                
                self.imageDataArray.append(data!)
                DispatchQueue.main.async
                    {
                        self.collectionView.reloadData()
                }
            })
        }
    }
    
    func createUpdateBarButtonItem()
    {
        let updateButton = UIBarButtonItem.init(title: "Update", style: .plain, target: self, action: #selector(updateUserInfo))
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
        userProfileImageView.layer.borderWidth=5.0
        userProfileImageView.layer.masksToBounds = false
        userProfileImageView.layer.borderColor = UIColor.white.cgColor
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.height/2
        userProfileImageView.clipsToBounds = true
        populateProfileImage()
    }
    
    func populateUserValues()
    {
        if firUser?.displayName == nil
        {
            let firstName = userInfo?.firstName!
            let lastName = userInfo?.lastName!
            let fullName = "\(firstName!) \(lastName!)"
            userNameLabel.text = fullName
            userNameField.text = fullName
        }else
        {
            userNameLabel.text = firUser?.displayName!
            userNameField.text = firUser?.displayName!
        }
        userEmailField.text = userInfo?.email!
    }
    
    func populateUserAddress()
    {
        let addressRef = FIRDatabase.database().reference().child("users").child((firUser?.uid)!).child("address")
        addressRef.observe(.value, with: { (snapshot) in
            
            if snapshot.exists()
            {
                let userAddress = Address(snapshot: snapshot)
                self.userAddressField.text = userAddress.street
                self.userCityField.text = userAddress.city
                self.userStateField.text = userAddress.state
                self.userZipCodeField.text = userAddress.zipCode
            }
        })
    }
    
    func populateProfileImage()
    {
        FIRDatabase.database().reference().child("users").child(firUser!.uid).child("profileImageID").observe(.value, with: { (snapshot) in
            
            let imageID = snapshot.value! as! String
            let ref = self.createProfileImageStorageReference()
            ref.child(imageID).data(withMaxSize: 3 * 1024 * 1024) { (data, error) in
                
                guard error == nil else
                {
                    DispatchQueue.main.async
                        {
                            self.utilityClass.errorAlert(title: "Image Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                            print("\n\(error.debugDescription)")
                    }
                    return
                }
                
                if let data = data
                {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async
                        {
                            self.userProfileImageView.contentMode = .scaleAspectFill
                            self.userProfileImageView.image = image
                    }
                }
            }
        })
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
    
    func updateUserInfo()
    {
        let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
        if userNameField.text != changeRequest?.displayName
        {
            changeRequest?.displayName = userNameField.text
            changeRequest?.commitChanges(completion: { (error) in
                
                guard error == nil else
                {
                    self.utilityClass.errorAlert(title: "Update Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                    return
                }
            })
        }
        
        if self.userEmailField.text != self.userInfo?.email
        {
            FIRAuth.auth()?.currentUser?.updateEmail(self.userEmailField.text!, completion: { (error) in
                
                guard error == nil else
                {
                    self.utilityClass.errorAlert(title: "Update Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                    return
                }
                
                FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                    guard error == nil else
                    {
                        self.utilityClass.errorAlert(title: "Email Verification Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                        return
                    }
                })
            })
        }
        
        if userAddressField.text != ""
        {
            FIRDatabase.database().reference().child("users/\(firUser!.uid)/address").child("street").setValue(userAddressField.text!)
        }
        
        if userStateField.text != ""
        {
            FIRDatabase.database().reference().child("users/\(firUser!.uid)/address").child("state").setValue(userStateField.text!)
        }
        
        if userCityField.text != ""
        {
            FIRDatabase.database().reference().child("users/\(firUser!.uid)/address").child("city").setValue(userCityField.text!)
        }
        
        if userZipCodeField.text != ""
        {
            FIRDatabase.database().reference().child("users/\(firUser!.uid)/address").child("zipCode").setValue(userZipCodeField.text!)
        }
        
        if userProfileImageView.image != UIImage(named: "profilePlaceholder")
        {
            let ref = createProfileImageStorageReference()
            let image = userProfileImageView.image
            let localFile = image?.jpeg(.medium)
            FIRDatabase.database().reference().child("users").child(firUser!.uid).child("profileImageID").setValue(localFile!.description)
            _ = ref.child(localFile!.description).put(localFile!, metadata: nil, completion: { (metadata, error) in
                guard let metadata = metadata else
                {
                    return
                }
                
                _ = metadata.downloadURL
            })
        }
        
        self.utilityClass.errorAlert(title: "Successful Update", message: "Your information was successfully updated!", cancelTitle: "Okay", view: self)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func editEvents(_ sender: UIButton)
    {
        performSegue(withIdentifier: "fromProfileToCreateEvent", sender: userEvent!)
    }
}

extension UserProfileViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        print("\nCollection View Image Data Array: \(self.imageDataArray.count)")
        return imageDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        print("\ncellForItemAt was called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserProfileCollectionViewCell
        print("imageDataArray Data: \(imageDataArray[indexPath.row])")
        
        cell.imageView.image = UIImage(data: imageDataArray[indexPath.row])
        cell.eventDataLabel.text = userEvent?.date
        cell.eventTitleLabel.text = userEvent?.title
        
        return cell
    }
}

extension UserProfileViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "fromProfileToCreateEvent", sender: userEvent!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "fromProfileToCreateEvent"
        {
            let destinationVC = segue.destination as! CreateEventViewController
            destinationVC.userEvent = sender as? Event
        }
    }
}

extension UserProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    @IBAction func editProfileImage()
    {
        let alert = UIAlertController(title: "Edit Profile Image", message: "Where can we get your photo from?", preferredStyle: .alert)
        let photoSelection = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.photoFromLibrary()
        }
        let cameraSelection = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.shootPhoto()
        }
        
        alert.addAction(photoSelection)
        alert.addAction(cameraSelection)
        present(alert, animated: true, completion: nil)
    }
    
    func photoFromLibrary()
    {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func shootPhoto()
    {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
}
