//
//  BikeTableViewCell.swift
//  SmartCycle
//
//  Created by Joao Duarte on 27/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit

class BikeTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var bikePhoto: UIImageView!
    @IBOutlet fileprivate weak var bikeNameLabel: UILabel!

    func populateData(item: BikeItem) {
        if let photo = item.photo {
            bikePhoto.image = photo
        }
        
        bikeNameLabel.text = item.brand
    }
}
