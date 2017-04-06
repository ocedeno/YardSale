//
//  Utility.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/23/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import UIKit

struct Utility
{
    func errorAlert(title: String, message: String, cancelTitle: String, view: UIViewController)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        DispatchQueue.main.async
        {
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    func createBackgroundImageView(view: UIView)
    {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        imageView.image = UIImage.greenBlurredBackground()
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
    }
}

extension UIImage {
    class func gorgeousImage() -> UIImage {
        return UIImage(named: "GorgeousImage")!
    }
    
    class func grassBackground() -> UIImage {
        return UIImage(named: "GrassBackground")!
    }
    
    class func vintageWoodBackground() -> UIImage {
        return UIImage(named: "VintageWoodBackground")!
    }
    
    class func yardSaleSign() -> UIImage {
        return UIImage(named: "YardSaleSign")!
    }
    
    class func greenGrassBackground() -> UIImage {
        return UIImage(named: "GreenGrassBackground")!
    }
    
    class func greenBlurredBackground() -> UIImage {
        return UIImage(named: "GreenBlurredBackground")!
    }
}
