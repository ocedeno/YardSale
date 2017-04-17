//
//  EventTableViewCell.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/24/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell
{
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
  
    @IBOutlet weak var startStopTime: UILabel!
    
    func updateEventCell(withDate: String, distance: String, time: String, headline: String, address: String, category: String, image: UIImage)
    {
        self.eventImageView.image = image
        self.dateLabel.text = withDate
        self.distanceLabel.text = distance
        self.headlineLabel.text = headline
        self.addressLabel.text = address
        self.categoryLabel.text = category
        self.startStopTime.text = time
    }
}
