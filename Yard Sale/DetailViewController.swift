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

class DetailViewController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    var userEvent: Event?
    var ref: FIRDatabaseReference? = nil
    var uniqueID: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        getUserEvent()
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
                }
        })
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
        let mapCenterCoordinates = CLLocationCoordinate2D(latitude: doubleLat! + 0.02, longitude: doubleLon!)
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
}
