//
//  AddressSelectionViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/29/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit
import MapKit

class AddressSelectionViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = LocationManager.sharedInstance
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    let utilityClass = Utiliy()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem)
    {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0
        {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start {(localSearchResponse, error) -> Void in
            
            guard localSearchResponse != nil else
            {
                self.utilityClass.errorAlert(title: "Address Error", message: "Location Not Found", cancelTitle: "Dismiss", view: self)
                
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = "Use this location? Select here."
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude:localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
            let coordinate:CLLocationCoordinate2D = self.pointAnnotation.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegionMake(coordinate, span)
            DispatchQueue.main.async
                {
                    self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
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
        let pin = view.annotation?.coordinate
        let createVC = navigationController?.viewControllers[1] as! CreateEventViewController
        createVC.locLon = pin?.longitude
        createVC.locLat = pin?.latitude
        createVC.addDictCompleted = true
        _ = navigationController?.popViewController(animated: true)

    }
}
