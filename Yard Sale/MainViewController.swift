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

    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var sidePanel: UIView!
    var viewWidthConstant: CGFloat = 0.3
    var viewWidth: CGFloat = 0.0
    var isPanelVisible = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupSidePanel()
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem)
    {
        
    }
    
    @IBAction func menuSlideAction(_ sender: UIBarButtonItem)
    {
        isPanelVisible = !isPanelVisible
        
        if isPanelVisible
        {
            alterViewPosition(true)
        }else
        {
            alterViewPosition(false)
        }
    }
    
    func alterViewPosition(_ sidePanelVisible: Bool)
    {
        viewWidth = viewWidthConstant * view.bounds.maxX
        
        if sidePanelVisible
        {
//            sidePanel.isHidden = !sidePanelVisible
            
            UIView.animate(withDuration: 0.7, animations:
            {
                self.mapView.frame.origin.x += self.viewWidth
                self.eventTableView.frame.origin.x += self.viewWidth
                self.titleBar.frame.origin.x += self.viewWidth
            })
        }else
        {
            UIView.animate(withDuration: 0.7, animations:
            {
                self.mapView.frame.origin.x = 0
                self.eventTableView.frame.origin.x = 0
                self.titleBar.frame.origin.x = 0
//                self.sidePanel.frame.origin.x = 0
            }, completion: { (complete) -> Void in
//                self.sidePanel.isHidden = !sidePanelVisible
            })
        }
    }
    
    func setupSidePanel()
    {
        sidePanel = UIView()
        sidePanel.isHidden = false
        viewWidth = viewWidthConstant * view.bounds.maxX
        sidePanel.frame = CGRect(x: 0, y: 0, width: viewWidthConstant * self.view.bounds.maxX, height:view.bounds.size.height)
        sidePanel.backgroundColor = UIColor.blue
        
        view.addSubview(sidePanel)
    }
}

