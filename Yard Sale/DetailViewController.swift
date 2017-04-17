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

class DetailViewController: UIViewController
{
    @IBOutlet weak var eventPhotoCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var enlargedImageView: UIImageView!
    @IBOutlet weak var imageViewOverlay: UIView!
    
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
        eventPhotoCollectionView.delegate = self
        
        let tapToDismissgesture = UITapGestureRecognizer(target: self, action: #selector(dismissImageSubview))
        enlargedImageView.addGestureRecognizer(tapToDismissgesture)
        imageViewOverlay.addGestureRecognizer(tapToDismissgesture)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        utilityClass.createBackgroundImageView(view: self.view)
        
        eventPhotoCollectionView.backgroundColor = UIColor.clear
        eventDescriptionTextView.isEditable = false
        
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.delegate = self
        
        imageViewOverlay.isHidden = true
        enlargedImageView.isHidden = true
    }
    
    func getUserEvent()
    {
        self.ref = FIRDatabase.database().reference().child("events").child(uniqueID!)
        self.ref?.observe(.value, with: { (snapshot) in
            
            guard snapshot.exists() else
            {
                return
            }
            
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
        }
    }

    func createImageStorageReference()
    {
        eventImageRef = nil
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        eventImageRef = imageRef.child(uniqueID!)
        
        populateDataArray()
    }
    
    func populateDataArray()
    {
        guard userEvent?.imageTitleDictionary != nil else { return }
        
        for item in (userEvent?.imageTitleDictionary)!
        {
            eventImageRef?.child(item.value).data(withMaxSize: 3 * 1024 * 1024, completion: { (data, error) in
                
                guard error == nil else
                {
                   return self.populateDataArray()
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
    
    
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem)
    {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}

extension DetailViewController: MKMapViewDelegate
{
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
        pointAnnotation.subtitle = "Select for Directions"
        
        let yourAnnotationAtIndex = 0
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: mapCenterCoordinates, span: span)
        
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(pointAnnotation)
        mapView.selectAnnotation(mapView.annotations[yourAnnotationAtIndex], animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView")
        if annotationView == nil
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return annotationView
    }
    
    func openMapForPlace() {
        
        let stringLat = userEvent?.addressDictionary?["latitude"] as! String
        let stringLon = userEvent?.addressDictionary?["longitude"] as! String
        
        let lat1 : NSString = stringLat as NSString
        let lng1 : NSString = stringLon as NSString
        
        let latitude:CLLocationDegrees =  lat1.doubleValue
        let longitude:CLLocationDegrees =  lng1.doubleValue
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = userEvent?.title
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        openMapForPlace()
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
        cell.imageView.image = image!
                
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        UIView.animate(withDuration: 0.7)
        {
            self.createEnlargedImageView(indexPath: indexPath.row)
        }
    }
    
    func createEnlargedImageView(indexPath: Int)
    {
        let image = UIImage(data: dataArray[indexPath])
        enlargedImageView?.image = image!
        enlargedImageView?.contentMode = .scaleAspectFit
        
        enlargedImageView.isHidden = false
        imageViewOverlay.isHidden = false
    }
    
    func dismissImageSubview()
    {
        imageViewOverlay.isHidden = true
        enlargedImageView.isHidden = true
    }
}
