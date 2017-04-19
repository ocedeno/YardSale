//
//  CreateEventViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/27/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CreateEventViewController: UIViewController, SSRadioButtonControllerDelegate
{
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var useNewLocation: SSRadioButton!
    @IBOutlet weak var useCurrentAddressButton: SSRadioButton!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var stopTimeField: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var displayEvent: UISwitch!
    @IBOutlet weak var eventPhotCollectionView: UICollectionView!
    @IBOutlet weak var addImageButton: UIButton!
    
    var radioButtonController: SSRadioButtonsController?
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    let utilityClass = Utility()
    let locationManager = LocationManager.sharedInstance
    var locLat: Double?
    var locLon: Double?
    var addDictionary: [String:AnyObject]?
    var addDictCompleted: Bool = false
    var imagesDirectoryPath:String?
    var images:[UIImage]?
    var titles:[String]?
    var dataArray: [Data] = []
    var taskFirebasePath: FIRDatabaseReference? = nil
    var uniqueEventID: String?
    var eventImageRef: FIRStorageReference?
    var lastImagePath: String?
    var userEvent: Event?
    var editingEvent: Bool = false
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    var count = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Create Event"
        let saveButton = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveEvent))
        self.navigationItem.rightBarButtonItem = saveButton
        
        radioButtonController = SSRadioButtonsController(buttons: useCurrentAddressButton, useNewLocation)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        self.view.addGestureRecognizer(gesture)
        
        taskFirebasePath = self.ref.ref.child("events").childByAutoId()
        uniqueEventID = taskFirebasePath?.key
        
        eventPhotCollectionView.dataSource = self
        eventPhotCollectionView.delegate = self
        eventPhotCollectionView.backgroundColor = UIColor.clear
        
        updateTextView()
        setTextFieldDelegate()
        utilityClass.activityIndicator(indicator: activityIndicator, view: self.view)
        activityIndicator.hidesWhenStopped = true
        
        if editingEvent
        {
            descriptionText.textColor = UIColor.black
            addImageButton.setTitle("Remove Old, and Add New Images", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        utilityClass.createBackgroundImageView(view: self.view)
        populateTextfieldValues()
        
        if addDictCompleted
        {
            createAddressDictionary(latitude: locLat!, longitude: locLon!)
        }else
        {
            useNewLocation.isSelected = false
            useNewLocation.toggleButon()
        }
        
        guard (userEvent?.addressDictionary == nil) else
        {
            let lat = (userEvent!.addressDictionary!["latitude"] as! NSString).doubleValue
            let lon = (userEvent!.addressDictionary!["longitude"] as! NSString).doubleValue
            locLat = lat
            locLon = lon
            useNewLocation.isSelected = true
            return
        }
    }
    
    internal func setTextFieldDelegate()
    {
        titleTextField.delegate = self
        dateTextField.delegate = self
        startTimeField.delegate = self
        stopTimeField.delegate = self
        descriptionText.delegate = self
    }
    
    internal func updateTextView()
    {
        let placeholderText = "Please provide a description of your event here..."
        descriptionText.clipsToBounds = true
        descriptionText.layer.cornerRadius = 10.0
        descriptionText.text = placeholderText
        descriptionText.textColor = UIColor(hex: "BBBAC2")
    }
    
    func populateTextfieldValues()
    {
        guard userEvent != nil else
        {
            return
        }
        
        titleTextField.text = userEvent?.title
        dateTextField.text = userEvent?.date
        startTimeField.text = userEvent?.startTime
        stopTimeField.text = userEvent?.stopTime
        descriptionText.text = userEvent?.description
        displayEvent.isOn = (userEvent?.active)!
        reloadImages()
    }
    
    internal func didSelectButton(_ aButton: UIButton?)
    {
        if aButton == useCurrentAddressButton
        {
            if CLLocationManager.locationServicesEnabled()
            {
                startLocationUpdater()
            }else
            {
                utilityClass.errorAlert(title: "Location Error", message: "We are not currently using your current location. Please accept our request to use your location for a smoother performance.", cancelTitle: "Okay", view: self)
            }
        }
    }
    
    func dismissPicker()
    {
        startTimeField.endEditing(true)
        stopTimeField.endEditing(true)
        dateTextField.endEditing(true)
        titleTextField.endEditing(true)
        descriptionText.endEditing(true)
    }
    
    internal func startLocationUpdater()
    {
        locationManager.startUpdatingLocationWithCompletionHandler({ (lat, lon, status, verboseMessage, error) in
            
            guard error == nil else
            {
                self.utilityClass.errorAlert(title: "Location Update Error", message: (error?.description)!, cancelTitle: "Dismiss", view: self)
                return
            }
            
            self.locLat = lat
            self.locLon = lon
            
            self.createAddressDictionary(latitude: lat, longitude: lon)
        })
    }
    
    fileprivate func createAddressDictionary(latitude: Double, longitude: Double)
    {
        self.locationManager.reverseGeocodeLocationWithLatLon(latitude: latitude, longitude: longitude, onReverseGeocodingCompletionHandler: { (dictionary, placemark, error) in
            
            guard error == nil else
            {
                DispatchQueue.main.async
                    {
                        self.utilityClass.errorAlert(title: "Location Update Error", message: (error?.description)!, cancelTitle: "Dismiss", view: self)
                }
                return
            }
            
            DispatchQueue.main.async
                {
                    self.addDictionary = dictionary as? [String:AnyObject]
            }
        })
    }
    
    @IBAction func selectLocationAction()
    {
        performSegue(withIdentifier: "getLocationSegue", sender: nil)
    }
    
    @IBAction func dateTextFieldEditing(_ sender: UITextField)
    {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.minimumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func startTimeTextFieldEditing(_ sender: UITextField)
    {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .time
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let date = dateFormatter.date(from: "8:00 AM")
        datePickerView.date = date!
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(startTimePickerValueChanged), for: .valueChanged)
    }
    
    func startTimePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        startTimeField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func stopTimeTextFieldEditing(_ sender: UITextField)
    {
        let timePickerView: UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = .time
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let date = dateFormatter.date(from: "1:00 PM")
        timePickerView.date = date!
        sender.inputView = timePickerView
        
        timePickerView.addTarget(self, action: #selector(stopTimePickerValueChanged), for: .valueChanged)
    }
    
    func stopTimePickerValueChanged(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        stopTimeField.text = dateFormatter.string(from: sender.date)
    }
    
    func createImageStorageReference()
    {
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        if !editingEvent {
            eventImageRef = imageRef.child(uniqueEventID!)
        }else
        {
            eventImageRef = imageRef.child((userEvent?.imageKey)!)
        }
    }
    
    func createImageTitleDictionary() -> [String:String]?
    {
        var stringDict: [String:String] = [:]
        if dataArray.count != 0
        {
            var count = 0
            for item in dataArray
            {
                count += 1
                let stringKey = "item\(count)"
                stringDict[stringKey] = item.description
            }
        }
        return stringDict
    }
    
    func checkForNetworkConnection()
    {
        guard utilityClass.isInternetAvailable() else
        {
            return utilityClass.errorAlert(title: "No Internet Connection", message: "In order to use this application successfully, please make sure you are connected to the internet.", cancelTitle: "Dismiss", view: self)
        }
    }
    
    func saveEvent()
    {
        activityIndicator.startAnimating()
        checkForNetworkConnection()
        if guardCheck()
        {
            dismissPicker()
            let dic: [String:AnyObject] = updateEvent()
            let userID = FIRAuth.auth()?.currentUser?.uid
            locationManager.stopUpdatingLocation()
            if editingEvent
            {
                let updateRef = FIRDatabase.database().reference().child("events").child(userEvent!.imageKey!)
                print(updateRef)
                let event = Event(withTitle: dic["title"] as! String,
                                  onDate: dic["date"] as! String,
                                  startTime: dic["startTime"] as! String,
                                  stopTime: dic["stopTime"] as! String,
                                  withDescription: dic["description"] as! String,
                                  userID: userID! ,
                                  activeEvent: displayEvent.isOn,
                                  locationLatitude: dic["locLat"] as! Double,
                                  locationLongitude: dic["locLon"] as! Double,
                                  addDict: dic["addressDictionary"] as! [String:AnyObject],
                                  imageTitleDict: dic["imageTitleDictionary"] as! [String:String],
                                  imagePathKey: (userEvent?.imageKey!)!
                )
                
                updateRef.updateChildValues(event.toDictionary() as! [AnyHashable : Any])
                if !dataArray.isEmpty
                {
                    savePhotosToFirebase(dataArray: dataArray)
                }
                self.activityIndicator.stopAnimating()
                performSegue(withIdentifier: "segueToDetailView", sender: userEvent?.imageKey!)
            }else
            {
                let event = Event(withTitle: dic["title"] as! String,
                                  onDate: dic["date"] as! String,
                                  startTime: dic["startTime"] as! String,
                                  stopTime: dic["stopTime"] as! String,
                                  withDescription: dic["description"] as! String,
                                  userID: userID! ,
                                  activeEvent: displayEvent.isOn,
                                  locationLatitude: dic["locLat"] as! Double,
                                  locationLongitude: dic["locLon"] as! Double,
                                  addDict: dic["addressDictionary"] as! [String:AnyObject],
                                  imageTitleDict: dic["imageTitleDictionary"] as! [String:String],
                                  imagePathKey: dic["imagePathKey"] as! String
                )
                
                taskFirebasePath?.setValue(event.toDictionary())
                FIRDatabase.database().reference().child("users/\(userID!)/events").child("event").setValue(event.imageKey!)
                if !dataArray.isEmpty
                {
                    savePhotosToFirebase(dataArray: dataArray)
                }
                self.activityIndicator.stopAnimating()
                performSegue(withIdentifier: "segueToDetailView", sender: taskFirebasePath?.key)
            }
        }
    }
    
    func savePhotosToFirebase(dataArray: [Data])
    {
        for image in dataArray
        {
            let localFile = image
            _ = eventImageRef?.child(image.description).put(localFile, metadata: nil, completion: { (metadata, error) in
                guard let metadata = metadata else
                {
                    return
                }
                
                _ = metadata.downloadURL
            })
        }
    }
    
    fileprivate func updateEvent() -> [String: AnyObject]
    {
        if userEvent?.addressDictionary != nil
        {
            addDictionary = userEvent?.addressDictionary
        }
        let dic =
            [
                "title" : titleTextField.text! as AnyObject,
                "date" : dateTextField.text! as AnyObject,
                "startTime" : startTimeField.text! as AnyObject,
                "stopTime" : stopTimeField.text! as AnyObject,
                "description" : descriptionText.text as AnyObject,
                "locLat": locLat as AnyObject,
                "locLon" : locLon as AnyObject,
                "addressDictionary" : addDictionary! as [String : AnyObject],
                "imageTitleDictionary" : createImageTitleDictionary()!,
                "imagePathKey" : taskFirebasePath!.key
                ] as [String : Any]
        
        
        return dic as [String : AnyObject]
    }
    
    fileprivate func guardCheck() -> Bool
    {
        let originalBorderColor = UIColor.init(colorLiteralRed: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        guard useCurrentAddressButton.isSelected || useNewLocation.isSelected else
        {
            utilityClass.errorAlert(title: "Save Error", message: "Please make a location selection.", cancelTitle: "Dismiss", view: self)
            return false
        }
        
        guard !(titleTextField.text!.isEmpty) else
        {
            utilityClass.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: titleTextField)
            return false
        }
        
        titleTextField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(dateTextField.text!.isEmpty) else
        {
            utilityClass.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: dateTextField)
            return false
        }
        
        dateTextField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(startTimeField.text!.isEmpty) else
        {
            utilityClass.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: startTimeField)
            return false
        }
        
        startTimeField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(stopTimeField.text!.isEmpty) else
        {
            utilityClass.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withFrame: stopTimeField)
            return false
        }
        
        stopTimeField.layer.borderColor = originalBorderColor.cgColor
        
        guard !(descriptionText.text.isEmpty) else
        {
            utilityClass.errorAlert(title: "Save Error", message: "Please make sure the selected fields have been filled.", cancelTitle: "Dismiss", view: self)
            updateBorder(withTextView: descriptionText)
            return false
        }
        
        guard dataArray.count > 0 else
        {
            utilityClass.errorAlert(title: "Save Error", message: "You must have at least one image of your event.", cancelTitle: "Try Again", view: self)
            return false
        }
        
        descriptionText.layer.borderColor = originalBorderColor.cgColor
        return true
    }
    
    fileprivate func updateBorder(withFrame frame: UITextField)
    {
        let redBorderColor = UIColor.red
        frame.layer.borderColor = redBorderColor.cgColor
        frame.layer.borderWidth = 1.0
        frame.layer.cornerRadius = 5.0
    }
    
    fileprivate func updateBorder(withTextView frame: UITextView)
    {
        let redBorderColor = UIColor.red
        
        frame.layer.borderColor = redBorderColor.cgColor
        frame.layer.borderWidth = 1.0
        frame.layer.cornerRadius = 5.0;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueToDetailView"
        {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.uniqueID = sender as? String
            
            destinationVC.navigationItem.setHidesBackButton(true, animated: true)
        } else if segue.identifier == "segueToImageDetail"
        {
            let destinationVC = segue.destination as! ImageViewController
            let image = sender as? UIImage
            destinationVC.image = image!
            destinationVC.imagePath = lastImagePath
        }
    }
}

extension CreateEventViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    @IBAction func choosePhoto(_ sender: UIButton)
    {
        if sender.titleLabel?.text == "Remove Old, and Add New Images"
        {
            createImageStorageReference()
            for item in dataArray
            {
                eventImageRef?.child(item.description).delete(completion: { (error) in
                    
                    guard error == nil else
                    {
                        return self.utilityClass.errorAlert(title: "Image Deletion Error", message: "There was an error deleting your images. Please try again later.", cancelTitle: "Dismiss", view: self)
                    }
                })
            }
            
            dataArray.removeAll()
            userEvent?.imageTitleDictionary?.removeAll()
            self.eventPhotCollectionView.reloadData()
            addImageButton.setTitle("Add Images", for: .normal)
        }else
        {
            self.createImagePath()
            self.createImageStorageReference()
            if dataArray.count < 10
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                present(imagePicker, animated: true, completion: nil)
            }else
            {
                utilityClass.errorAlert(title: "Image Selection Alert", message: "You can only select 10 images at most.", cancelTitle: "Dismiss", view: self)
            }
        }
    }
    
    func createImagePath()
    {
        images = []
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectorPath: String = paths[0]
        if userEvent == nil
        {
            imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker/\(uniqueEventID!)")
        } else
        {
            imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker/\((userEvent?.imageKey)!)")
        }
        var objcBool: ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath!, isDirectory: &objcBool)
        
        if isExist == false
        {
            do
            {
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath!, withIntermediateDirectories: true, attributes: nil)
            }catch
            {
                print("\nSomething went wrong while creating a new folder")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let imageRecieved: UIImage?
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageRecieved = image
        } else{
            print("Something went wrong")
            return
        }
        var imagePath = NSDate().description
        imagePath = imagePath.replacingOccurrences(of: " ", with: "")
        imagePath = (imagesDirectoryPath?.appending("/\(imagePath).png"))!
        let data = imageRecieved?.jpeg(.low)
        let success = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        if success
        {
            self.reloadImages()
            self.performSegue(withIdentifier: "segueToImageDetail", sender: imageRecieved!)
            self.dismiss(animated: true)
        }
    }
    
    func reloadImages()
    {
        if userEvent == nil
        {
            do
            {
                images?.removeAll()
                dataArray.removeAll()
                titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath!)
                for image in titles!
                {
                    lastImagePath = imagesDirectoryPath?.appending("/\(image)")
                    let data = FileManager.default.contents(atPath: lastImagePath!)
                    dataArray.append(data!)
                    let image = UIImage(data: data!)
                    images!.append(image!)
                    eventPhotCollectionView.reloadData()
                }
            }catch
            {
                print("\nError adding images to images array.")
            }
            
        }else
        {
            self.createImageStorageReference()
            guard userEvent?.imageTitleDictionary?.count != 0 else
            {
                do
                {
                    images?.removeAll()
                    dataArray.removeAll()
                    titles = try? FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath!)
                    for image in titles!
                    {
                        lastImagePath = imagesDirectoryPath?.appending("/\(image)")
                        let data = FileManager.default.contents(atPath: lastImagePath!)
                        dataArray.append(data!)
                        let image = UIImage(data: data!)
                        images!.append(image!)
                        eventPhotCollectionView.reloadData()
                    }
                }catch
                {
                    print("\nError adding images to images array.")
                }
                
                return
            }
            
            for ref in (self.userEvent?.imageTitleDictionary)!
            {
                self.eventImageRef?.child(ref.value).data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                    guard error == nil else
                    {
                       return self.utilityClass.errorAlert(title: "Image Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                    }
                    
                    self.dataArray.append(data!)
                    self.eventPhotCollectionView.reloadData()
                })
            }
        }
    }
}

extension CreateEventViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! EventPhotoCollectionViewCell
        let image = UIImage(data: dataArray[indexPath.row])
        DispatchQueue.main.async
            {
                cell.imageView.image = image!
        }
        return cell
    }
}

extension CreateEventViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print("Did Select")
    }
}

extension CreateEventViewController: UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if startTimeField == textField
        {
            startTimeField.text = "8:00 AM"
        }else if stopTimeField == textField
        {
            stopTimeField.text = "1:00 PM"
        }else if textField == dateTextField
        {
            let dateFormatter = DateFormatter()
            let currentDate = Date()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateTextField.text = dateFormatter.string(from: currentDate)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case titleTextField:
            dateTextField.becomeFirstResponder()
            break
            
        case dateTextField:
            startTimeField.becomeFirstResponder()
            break
            
        case startTimeField:
            stopTimeField.becomeFirstResponder()
            break
            
        case stopTimeField:
            descriptionText.becomeFirstResponder()
            break
            
        default:
            break
        }
        
        return true
    }
}

extension CreateEventViewController: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionText && count == 0
        {
            count += 1
            descriptionText.text = ""
            descriptionText.textColor = UIColor.black
        }
        self.view.frame.origin.y -= 70
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == ""
        {
            count = 0
            updateTextView()
        }
        self.view.frame.origin.y += 70
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
