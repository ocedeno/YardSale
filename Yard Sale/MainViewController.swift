//
//  ViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/19/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class MainViewController: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var locationManager = LocationManager.sharedInstance
    var ref: FIRDatabaseReference? = nil
    let utilityClass = Utiliy()
    var eventsArray = [Event]()
    var locationOne, locationTwo: CLLocation?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        eventTableView.backgroundColor = UIColor.clear
        mapView.delegate = self
        eventTableView.delegate = self
        eventTableView.dataSource = self
        getCurrentLocation()
        populateEventsArray()
        addSlideMenuButton()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is signed in.")
            } else {
                print("User is signed out.")
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem)
    {
        openViewControllerBasedOnIdentifier("CreateEventVC")
        locationManager.stopUpdatingLocation()
    }
    
    func populateEventsArray()
    {
        self.ref = FIRDatabase.database().reference().child("events")
        self.ref?.queryOrdered(byChild: "userID").observe(.value, with: { snapshot in
            
            var array: [Event] = []
            for item in snapshot.children
            {
                let event = Event(snapshot: item as! FIRDataSnapshot)
                array.append(event)
            }
            
            self.eventsArray = array
            self.eventTableView.reloadData()
            self.reloadEventsToMapView()
        })
    }
    
    func getCurrentLocation()
    {
        locationManager.startUpdatingLocationWithCompletionHandler { (lat, lon, status, verboseMessage, error) in
            
            guard error == nil else
            {
                self.utilityClass.errorAlert(title: "Location Update Error", message: (error?.description)!, cancelTitle: "Dismiss", view: self)
                return
            }
            
            self.setMapRegion(lon: lon, lat: lat)
        }
    }
    
    func setMapRegion(lon: Double, lat: Double)
    {
        let lon = lon
        let lat = lat
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }
    
    func reloadEventsToMapView()
    {
        for event in eventsArray
        {
            let latitude = event.locLat
            let longitude = event.locLon
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude!), longitude: CLLocationDegrees(longitude!))
            pin.title = event.title!
            
            mapView.addAnnotation(pin)
        }
    }

    func getDistance(locationTwo: CLLocation) -> String
    {
        let lat = locationManager.latitude
        let lon = locationManager.longitude
        locationOne = CLLocation(latitude: lat, longitude: lon)
        let distanceMeters = locationTwo.distance(from: locationOne!)
        let milesConversion = 0.000621371192
        let distanceMiles = distanceMeters * milesConversion
        let distanceString = String(format: "%.2f", distanceMiles)

        return String("\(distanceString) miles")
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")! as! EventTableViewCell
        let image = UIImage(named: "gorgeousimage")
        let cellAddress: String = "\(eventsArray[indexPath.row].addressDictionary!["locality"]!), \(eventsArray[indexPath.row].addressDictionary!["administrativeArea"]!)"
        locationTwo = CLLocation(latitude: eventsArray[indexPath.row].locLat!, longitude: eventsArray[indexPath.row].locLon!)
        cell.updateEventCell(withDate: eventsArray[indexPath.row].date!, distance: getDistance(locationTwo: locationTwo!), headline: eventsArray[indexPath.row].title!, address: cellAddress, category: eventsArray[indexPath.row].description!, image: image!)
        
        return cell
    }
}
