//
//  ShopLocationAnnotation.swift
//  SmartCycle
//
//  Created by Joao Duarte on 26/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import MapKit

class ShopLocationAnnotation: NSObject, MKAnnotation {
    var identifier = "shop location"
    var coordinate: CLLocationCoordinate2D
    var shopItem: StoreItem?
    var title: String?

    init(item: StoreItem){
        self.coordinate = (item.location?.coordinate)!
        self.shopItem = item
    }
}
