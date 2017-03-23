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

class MainViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var sidePanel: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem)
    {
        
    }
    @IBAction func menuSlideAction(_ sender: UIBarButtonItem)
    {
        
    }
}

