//
//  Utility.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/23/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

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
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

extension UIImage {
    class func homePlaceholder() -> UIImage {
        return UIImage(named: "HomePlaceholder")!
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
    
    enum JPEGQuality: CGFloat
    {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    func jpeg(_ quality: JPEGQuality) -> Data?
    {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }    
}
