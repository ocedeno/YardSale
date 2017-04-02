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
    var idArray: [String]?
    var locationOne, locationTwo: CLLocation?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Yard Sale"
        eventTableView.backgroundColor = UIColor.clear
        mapView.delegate = self
        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        getCurrentLocation()
        addSlideMenuButton()
        
        setupBackgroundView()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        eventTableView.reloadData()
        reloadEventsToMapView()
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is signed in.")
            } else {
                print("User is signed out.")
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func setupBackgroundView()
    {
        eventTableView.tableFooterView = UIView()
        let blurredBackgroundView = BlurredBackgroundView(frame: .zero)
        eventTableView.backgroundView = blurredBackgroundView
        eventTableView.separatorEffect = UIVibrancyEffect(blurEffect: blurredBackgroundView.blurView.effect as! UIBlurEffect)
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem)
    {
        openViewControllerBasedOnIdentifier("CreateEventVC")
        locationManager.stopUpdatingLocation()
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
            self.populateEventsArray()
            self.eventTableView.reloadData()
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
    
    func populateEventsArray()
    {
        self.ref = FIRDatabase.database().reference().child("events")
        self.ref?.queryOrdered(byChild: "userID").observe(.value, with: { snapshot in
            
            var array: [Event] = []
            var arrayID: [String] = []
            for item in snapshot.children
            {
                let snap = item as! FIRDataSnapshot
                let event = Event(snapshot: snap)
                array.append(event)
                arrayID.append(snap.key)
            }
            
            self.eventsArray = array
            self.idArray = arrayID
            self.eventTableView.reloadData()
            self.reloadEventsToMapView()
        })
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
        let lat = locationManager.lastKnownLatitude
        let lon = locationManager.lastKnownLongitude
        locationOne = CLLocation(latitude: lat, longitude: lon)
        let distanceMeters = locationTwo.distance(from: locationOne!)
        let milesConversion = 0.000621371192
        let distanceMiles = distanceMeters * milesConversion
        let distanceString = String(format: "%.2f", distanceMiles)

        return String(distanceString)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let eventLat = eventsArray[indexPath.row].addressDictionary!["latitude"]! as! String
        let eventLon = eventsArray[indexPath.row].addressDictionary!["longitude"]! as! String
        let doubleLat = Double(eventLat)
        let doubleLon = Double(eventLon)
        locationTwo = CLLocation(latitude: doubleLat!, longitude: doubleLon!)
        let distance = getDistance(locationTwo: locationTwo!)
        eventsArray[indexPath.row].distance = distance
        eventsArray.sort { Double($0.distance) ?? 0.00 < Double($1.distance) ?? 0.00}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")! as! EventTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.updateEventCell(withDate: eventsArray[indexPath.row].date!,
                             distance: "\(eventsArray[indexPath.row].distance) mi.",
                             headline: eventsArray[indexPath.row].title!,
                             address: "\(eventsArray[indexPath.row].addressDictionary!["locality"]!), \(eventsArray[indexPath.row].addressDictionary!["administrativeArea"]!)",
                             category: eventsArray[indexPath.row].description!,
                             image: UIImage(named: "gorgeousimage")!
                            )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "segueToDetailView", sender: idArray?[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationVC = segue.destination as! DetailViewController
        destinationVC.uniqueID = sender as? String
        
    }
}
