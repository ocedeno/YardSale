//
//  DetailViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/29/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorageUI

class DetailViewController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var eventPhotoCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    var userEvent: Event?
    var ref: FIRDatabaseReference? = nil
    var eventImageRef: FIRStorageReference? = nil
    var uniqueID: String?
    var dataArray: [Data] = []
    var dataStringArray: [String] = []
    var uniqueEventID: String?
    let utilityClass = Utility()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if self == navigationController?.viewControllers[1] as? DetailViewController
        {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        getUserEvent()
        eventPhotoCollectionView.dataSource = self
    }
    
    func getUserEvent()
    {
        self.ref = FIRDatabase.database().reference().child("events").child(uniqueID!)
        self.ref?.observe(.value, with: { (snapshot) in
            
            self.userEvent = Event(snapshot: snapshot)
            DispatchQueue.main.async
                {
                    self.populateMap()
                    self.populateValues()
                    self.getuserImages()
            }
        })
    }
    
    func getuserImages()
    {
        if userEvent?.imageTitleDictionary?.count != 0
        {
            createImageStorageReference()
            populateDataArray()
        }
    }
    
    func createImageStorageReference()
    {
        eventImageRef = nil
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        eventImageRef = imageRef.child(uniqueID!)
    }
    
    func populateDataArray()
    {
        guard userEvent?.imageTitleDictionary != nil else
        {
            print("\nNo images from User.")
            return
        }
        for item in (userEvent?.imageTitleDictionary)!
        {
            eventImageRef?.child(item.value).data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                
                guard error == nil else
                {
                    DispatchQueue.main.async
                        {
                            self.utilityClass.errorAlert(title: "Image Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                            print("\n\(error.debugDescription)")
                    }
                    return
                }
                
                self.dataArray.append(data!)
                self.eventPhotoCollectionView.reloadData()
            })
        }
    }
    
    func populateValues()
    {
        eventTitleLabel.text = userEvent?.title!
        eventTimeLabel.text = "From: \(String(describing: userEvent!.startTime!)) - \(String(describing: userEvent!.stopTime!))"
        eventDateLabel.text = "On: \(userEvent!.date!)"
        eventDescriptionTextView.text = userEvent?.description!
    }
    
    func populateMap()
    {
        let pointAnnotation = MKPointAnnotation()
        let stringLat = userEvent?.addressDictionary?["latitude"] as! String
        let stringLon = userEvent?.addressDictionary?["longitude"] as! String
        let doubleLat = Double(stringLat)
        let doubleLon = Double(stringLon)
        let mapCenterCoordinates = CLLocationCoordinate2D(latitude: doubleLat! + 0.01, longitude: doubleLon!)
        let coordinates = CLLocationCoordinate2D(latitude: doubleLat!, longitude: doubleLon!)
        
        pointAnnotation.coordinate = coordinates
        var addressString = userEvent?.addressDictionary?["formattedAddress"] as! String
        
        if let dotRange = addressString.range(of: ",")
        {
            addressString.removeSubrange(dotRange.lowerBound..<addressString.endIndex)
        }
        
        pointAnnotation.title = addressString
        
        let yourAnnotationAtIndex = 0
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: mapCenterCoordinates, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(pointAnnotation)
        mapView.selectAnnotation(mapView.annotations[yourAnnotationAtIndex], animated: true)
    }
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem)
    {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}

extension DetailViewController: UICollectionViewDataSource
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
