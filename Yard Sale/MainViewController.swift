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
    let utilityClass = Utiliy()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        self.addSlideMenuButton()
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        utilityClass.errorAlert(title: "Map Error", message: error.localizedDescription, cancelTitle: "Dismiss", view: self)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")! as! EventTableViewCell
        let coordinates = CLLocationCoordinate2D(latitude: 26.0960880, longitude: -80.1886040)
        let image = getMapCellImage(withCoordinates: coordinates, imageView: cell.eventImageView)
        cell.updateEventCell(withDate: "Mar 24", distance: "2.4 mi", headline: "Get the best toys for 4-6", address: "18424 NW 11th CT", category: "*Children Clothes *Children Toys *Household Items *Electronics *Kids Shoes", image: image)
        
        return cell
    }
    
    func getMapCellImage(withCoordinates coordinates: CLLocationCoordinate2D, imageView: UIImageView) -> UIImage
    {
        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:blue|\(coordinates.latitude),\(coordinates.longitude)&\("zoom=13&size=\(2 * Int(imageView.frame.size.width))\(2 * Int(imageView.frame.size.height))")&sensor=true"
        let mapUrl: URL = NSURL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)! as URL
        let data = try! NSData(contentsOf: mapUrl) as Data
        let image: UIImage = UIImage(data: data)!
        
        return image
    }
}
