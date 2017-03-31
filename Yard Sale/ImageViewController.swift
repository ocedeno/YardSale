//
//  ImageViewController.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/31/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var imagePath: String?
    var fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = self.image
        imageView.backgroundColor = UIColor.black
    }
    
    @IBAction func saveImage(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteImage()
    {
        print(imagePath!)
        let createVC = navigationController?.viewControllers[1] as! CreateEventViewController
        try! fileManager.removeItem(atPath: imagePath!)
        createVC.reloadImages()
        createVC.eventPhotCollectionView.reloadData()
        
        navigationController?.popToViewController(createVC, animated: true)
    }
}
