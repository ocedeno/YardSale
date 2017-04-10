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
    var mapOverlayView: UIView?
    var currentLocationButton: UIButton?
    var chooseLocationButton: UIButton?
    var searchForLocation: UITextField?
    var buttonHeightConstant: CGFloat = 0.096
    var buttonWidthConstant: CGFloat = 0.45
    
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
        setupInitialMapView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        eventTableView.backgroundColor = UIColor.clear
        getCurrentLocation()
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
    
    func setupInitialMapView()
    {
        createMapOverlay()
    }
    
    func createMapOverlay()
    {
        mapOverlayView = UIView(frame: self.mapView.frame)
        mapOverlayView?.layer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        mapView.addSubview(mapOverlayView!)
        
        currentLocationButton = UIButton()
        chooseLocationButton = UIButton()
        setupOverlayButtons(button: currentLocationButton!)
        setupOverlayButtons(button: chooseLocationButton!)
    }
    
    func setupOverlayButtons(button: UIButton)
    {
        let buttonHeight: CGFloat = buttonHeightConstant * mapView.frame.height
        let buttonWidth: CGFloat = buttonWidthConstant * mapView.frame.width
        let mapViewCenterX = mapView.center.x
        let mapViewCenterY = mapView.center.y
        
        button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.backgroundColor = UIColor.black.cgColor
        button.center.x = mapViewCenterX
        button.titleLabel?.textColor = UIColor.green
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        if button == currentLocationButton
        {
            button.setTitle("Use Current Location", for: .normal)
            button.center.y = mapViewCenterY
            button.addTarget(self, action: #selector(useCurrentLocation), for: .touchUpInside)
        }else
        {
            button.setTitle("Select a Location", for: .normal)
            button.center.y = mapViewCenterY + 50
            button.addTarget(self, action: #selector(chooseLocation), for: .touchUpInside)
        }
        
        mapOverlayView?.addSubview(button)
    }
    
    func useCurrentLocation()
    {
        if LocationManager.sharedInstance.isRunning
        {
            reloadEventsToMapView()
            dismissSubview()
        }else
        {
            LocationManager.sharedInstance.startUpdatingLocationWithCompletionHandler({ (lat, long, status, message, error) in
                guard error == nil else
                {
                    self.utilityClass.errorAlert(title: "Location Error", message: (error?.description)!, cancelTitle: "Dismiss", view: self)
                    return
                }
                
                if LocationManager.sharedInstance.isRunning
                {
                    self.reloadEventsToMapView()
                    self.dismissSubview()
                }else
                {
                    self.utilityClass.errorAlert(title: "Location Error", message: "Cannot use Current Location unless accepted by user.", cancelTitle: "Dismiss", view: self)
                }
            })
        }
    }
    
    func chooseLocation()
    {
        dismissTextfields()
    }
    
    func createSearchField()
    {
        searchForLocation = UITextField()
        searchForLocation!.delegate = self
        let textFieldHeight: CGFloat = buttonHeightConstant * mapView.frame.height
        let textFieldWidth: CGFloat = buttonWidthConstant * mapView.frame.width
        let mapViewCenterX = mapView.center.x
        let mapViewCenterY = mapView.center.y
        searchForLocation!.frame = CGRect(x: 0, y: 0, width: textFieldWidth, height: textFieldHeight)
        searchForLocation!.layer.cornerRadius = searchForLocation!.frame.height / 2
        searchForLocation!.center.x = mapViewCenterX
        searchForLocation!.center.y = mapViewCenterY
        searchForLocation!.layer.backgroundColor = UIColor.lightGray.cgColor
        searchForLocation!.placeholder = "Enter City or Zip"
        searchForLocation!.textColor = UIColor.white
        searchForLocation!.clearsOnBeginEditing = true
        searchForLocation!.textAlignment = .center
        searchForLocation?.autocorrectionType = .no
        searchForLocation?.returnKeyType = .go
        
        self.mapView.addSubview(searchForLocation!)
    }
    
    func dismissSubview()
    {
        UIView.animate(withDuration: 1.0)
        {
            self.mapOverlayView!.frame.origin.y -= self.mapView.frame.maxY
        }
    }
    
    func dismissTextfields()
    {
        UIView.animate(withDuration: 0.5,
                       animations:
            {
                self.currentLocationButton?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.chooseLocationButton?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.6)
                        {
                            self.currentLocationButton?.transform = CGAffineTransform(scaleX: 0, y: 0)
                            self.chooseLocationButton?.transform = CGAffineTransform(scaleX: 0, y: 0)
                        }
        })
        
        createSearchField()
    }
    
    func redirectMapRegion()
    {
        guard let address = searchForLocation?.text else
        {
            utilityClass.errorAlert(title: "Blank Field", message: "Please enter your search location.", cancelTitle: "Dismiss", view: self)
            return
        }

        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemark, error) in
            
            guard error == nil else
            {
                self.utilityClass.errorAlert(title: "Location Error", message: (error?.localizedDescription)!, cancelTitle: "Dismiss", view: self)
                return
            }
            
            let selectedPlacemark: CLPlacemark = (placemark?[0])!
            let searchLat = selectedPlacemark.location?.coordinate.latitude
            let searchLon = selectedPlacemark.location?.coordinate.longitude
            self.setMapRegion(lon: searchLon!, lat: searchLat!)
            self.locationOne = CLLocation(latitude: searchLat!, longitude: searchLon!)
            self.searchForLocation?.isHidden = true
            self.dismissSubview()
            self.appendDistanceToEventsArray(currentLocation: false)
        }
        
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
            self.appendDistanceToEventsArray(currentLocation: true)
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
    
    func getDistance(locationOne: CLLocation, locationTwo: CLLocation) -> String
    {
        let distanceMeters = locationOne.distance(from: locationTwo)
        let milesConversion = 0.000621371192
        let distanceMiles = distanceMeters * milesConversion
        let distanceString = String(format: "%.2f", distanceMiles)
        
        return String(distanceString)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueToDetailView"
        {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.uniqueID = sender as? String
        }
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
    
    func appendDistanceToEventsArray(currentLocation: Bool)
    {
        if currentLocation
        {
            let locOneLon = locationManager.lastKnownLongitude
            let locOneLat = locationManager.lastKnownLatitude
            locationOne = CLLocation(latitude: locOneLat, longitude: locOneLon)
        }
        
        for event in eventsArray
        {
            let eventLat = event.addressDictionary!["latitude"]! as! String
            let eventLon = event.addressDictionary!["longitude"]! as! String
            let doubleLat = Double(eventLat)
            let doubleLon = Double(eventLon)
            locationTwo = CLLocation(latitude: doubleLat!, longitude: doubleLon!)
            let newDistance = getDistance(locationOne: locationOne!, locationTwo: locationTwo!)
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

extension MainViewController: UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.placeholder = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == searchForLocation
        {
            textField.resignFirstResponder()
            redirectMapRegion()
        }
        
        return true
    }
}

class MyPointAnnotation:MKPointAnnotation
{
    var imageKey: String?
}


