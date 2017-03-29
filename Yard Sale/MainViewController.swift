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
    
    var locationManager: CLLocationManager!
    var ref: FIRDatabaseReference? = nil
    let utilityClass = Utiliy()
    var eventsArray = [Event]()
    var locationOne, locationTwo: CLLocation?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
        })
        
        self.determineCurrentLocation()
        self.addSlideMenuButton()
        eventTableView.backgroundColor = UIColor.clear
        mapView.delegate = self
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(true)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is signed in.")
            } else {
                print("User is signed out.")
            }
        }
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem)
    {
        openViewControllerBasedOnIdentifier("CreateEventVC")
    }
}

extension MainViewController
{
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentLocation: CLLocation = locations[0] as CLLocation
        locationOne = currentLocation
        manager.stopUpdatingLocation()
        let lon = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        utilityClass.errorAlert(title: "Map Error", message: error.localizedDescription, cancelTitle: "Dismiss", view: self)
    }
    
    func getDistance(locationTwo: CLLocation) -> String
    {
        let distance = locationTwo.distance(from: self.locationOne!)
        let distString = Int(distance)
        return String("\(distString) miles")
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
        let cellAddress: String = "\(eventsArray[indexPath.row].addressDictionary!["City"]!), \(eventsArray[indexPath.row].addressDictionary!["State"]!)"
        locationTwo = CLLocation(latitude: eventsArray[indexPath.row].locLat!, longitude: eventsArray[indexPath.row].locLon!)
        cell.updateEventCell(withDate: eventsArray[indexPath.row].date!, distance: getDistance(locationTwo: locationTwo!), headline: eventsArray[indexPath.row].title!, address: cellAddress, category: eventsArray[indexPath.row].description!, image: image!)
        
        return cell
    }
    
    
}
