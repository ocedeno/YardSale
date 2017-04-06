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
    let utilityClass = Utility()
    var eventsArray = [Event]()
    var idArray: [String]?
    var locationOne, locationTwo: CLLocation?
    var dataArray: [String : Dictionary<String, Data>]?
    var eventImageRef: FIRStorageReference? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        eventTableView.delegate = self
        eventTableView.dataSource = self
        getCurrentLocation()
        addSlideMenuButton()
        setupBackgroundTableView()
        setupBackgroundNavView()
        populateEventsArray()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        eventTableView.backgroundColor = UIColor.clear
        getCurrentLocation()
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
    
    func setupBackgroundNavView()
    {
        self.title = "Yard Sale"
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "YardSale", size: 20)!]
        let image = UIImage(named: "NavBarGreenGrassBackground")
        nav?.contentMode = .scaleAspectFit
        nav?.setBackgroundImage(image, for: .default)
    }
    
    func setupBackgroundTableView()
    {
        eventTableView.tableFooterView = UIView()
        let blurredBackgroundView = BlurredBackgroundView(frame: .zero)
        blurredBackgroundView.blurView.effect = UIBlurEffect(style: .light)
        blurredBackgroundView.imageView.image = UIImage.greenGrassBackground()
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
            DispatchQueue.main.async
                {
                    print("\n***updated Location***")
                    self.setMapRegion(lon: lon, lat: lat)
                    self.populateEventsArray()
            }
        }
    }
    
    func setMapRegion(lon: Double, lat: Double)
    {
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        
        self.mapView.setRegion(region, animated: false)
        self.mapView.showsUserLocation = true
    }
    
    func populateEventsArray()
    {
        self.ref = FIRDatabase.database().reference().child("events")
        self.ref?.queryOrdered(byChild: "distance").observe(.value, with: { snapshot in
            
            var array: [Event] = []
            for item in snapshot.children
            {
                let snap = item as! FIRDataSnapshot
                let event = Event(snapshot: snap)
                array.append(event)
            }
            
            self.eventsArray = array
            self.appendDistanceToEventsArray()
            self.reloadEventsToMapView()
        })
    }
    
    func reloadEventsToMapView()
    {
        for event in eventsArray
        {
            let latitude = event.locLat
            let longitude = event.locLon
            let pin = MyPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude!), longitude: CLLocationDegrees(longitude!))
            pin.title = event.title!
            pin.imageKey = event.imageKey!
            
            mapView.addAnnotation(pin)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView")
        if annotationView == nil
        {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.isDraggable = true
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let myPin = view.annotation! as! MyPointAnnotation
        performSegue(withIdentifier: "segueToDetailView", sender: myPin.imageKey)
    }
    
    func getDistance(locationTwo: CLLocation) -> String
    {
        let lat = locationManager.lastKnownLatitude
        let lon = locationManager.lastKnownLongitude
        locationOne = CLLocation(latitude: lat, longitude: lon)
        let distanceMeters = locationOne!.distance(from: locationTwo)
        let milesConversion = 0.000621371192
        let distanceMiles = distanceMeters * milesConversion
        let distanceString = String(format: "%.2f", distanceMiles)
        
        return String(distanceString)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationVC = segue.destination as! DetailViewController
        destinationVC.uniqueID = sender as? String
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        createImageStorageReference(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")! as! EventTableViewCell
        cell.backgroundColor = UIColor.clear

        cell.updateEventCell(withDate: self.eventsArray[indexPath.row].date!,
                             distance: "\(self.eventsArray[indexPath.row].distance) mi.",
                             headline: self.eventsArray[indexPath.row].title!,
                              address: "\(self.eventsArray[indexPath.row].addressDictionary!["locality"]!), \(self.eventsArray[indexPath.row].addressDictionary!["administrativeArea"]!)",
                             category: self.eventsArray[indexPath.row].description!,
                                image: UIImage.vintageWoodBackground()
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "segueToDetailView", sender: eventsArray[indexPath.row].imageKey!)
    }
    
    func appendDistanceToEventsArray()
    {
        for event in eventsArray
        {
            let eventLat = event.addressDictionary!["latitude"]! as! String
            let eventLon = event.addressDictionary!["longitude"]! as! String
            let doubleLat = Double(eventLat)
            let doubleLon = Double(eventLon)
            locationTwo = CLLocation(latitude: doubleLat!, longitude: doubleLon!)
            let newDistance = getDistance(locationTwo: locationTwo!)
            event.distance = newDistance
        }
        
        eventsArray.sort { Double($0.distance)! < Double($1.distance)!}
        eventTableView.reloadData()
    }
    
    func createImageStorageReference(indexPath: IndexPath)
    {
        eventImageRef = nil
        let storage = FIRStorage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images")
        eventImageRef = imageRef.child(eventsArray[indexPath.row].imageKey!)
    }
}

class MyPointAnnotation:MKPointAnnotation
{
    var imageKey: String?
}


