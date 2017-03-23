//
//  Utility.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/23/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import UIKit

struct Utiliy
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
}
