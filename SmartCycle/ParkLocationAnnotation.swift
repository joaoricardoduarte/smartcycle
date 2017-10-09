//
//  ParkLocationAnnotation.swift
//  SmartCycle
//
//  Created by Joao Duarte on 25/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import MapKit

class ParkLocationAnnotation: NSObject, MKAnnotation {
    var identifier = "park location"
    var coordinate: CLLocationCoordinate2D
    var parkItem: ParkItem?
    var title: String?

    init(item: ParkItem){
        self.coordinate = (item.location?.coordinate)!
        self.parkItem = item
    }
}
