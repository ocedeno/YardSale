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
        
        self.addSlideMenuButton()
        eventTableView.backgroundColor = UIColor.clear
        mapView.delegate = self
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.determineCurrentLocation()
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
        manager.stopUpdatingLocation()
        let lon = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    func getCity(withCoordinates lat: Double, lon: Double)
    {
        let location: CLLocation = CLLocation(latitude: lat , longitude: lon)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if placeMark != nil
            {
                // Address dictionary
                print("\n*Address Dictionary: \(placeMark.addressDictionary)*")
                
                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                    print("\n**Location Name:\(locationName)**")
                }
                
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    print("\n***Street: \(street)***")
                }
                
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    print("\n****City: \(city)****")
                }
                
                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                    print("\n***Zip: \(zip)***")
                }
                
                // Country
                if let country = placeMark.addressDictionary!["Country"] as? NSString {
                    print("\n**Country: \(country)**\n")
                }
            }else
            {
                self.utilityClass.errorAlert(title: "Location Error", message: "There was no placemarker near your pin. Please try again.", cancelTitle: "Try Again", view: self)
            }
            
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        utilityClass.errorAlert(title: "Map Error", message: error.localizedDescription, cancelTitle: "Dismiss", view: self)
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
        getCity(withCoordinates: eventsArray[indexPath.row].locLat!, lon: eventsArray[indexPath.row].locLon!)
        cell.updateEventCell(withDate: eventsArray[indexPath.row].date!, distance: "2.4 mi", headline: eventsArray[indexPath.row].title!, address: "need to figure out", category: eventsArray[indexPath.row].description!, image: image!)
        
        return cell
    }
    
    
}
