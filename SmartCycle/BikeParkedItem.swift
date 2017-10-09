//
//  BikeParkedItem.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 26/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import CoreLocation

class BikeParkedItem: NSObject, NSCoding {
    var address: String?
    var parkId: String?
    var photo: UIImage?
    var location: CLLocation?

    struct Keys {
        static let address = "address"
        static let parkId = "parkId"
        static let photo = "photo"
        static let location = "location"
    }

    init(address: String, parkId: String, photo: UIImage?, location: CLLocation) {
        self.address = address
        self.parkId = parkId
        self.photo = photo
        self.location = location
    }

    required init?(coder aDecoder: NSCoder) {
        if let address = aDecoder.decodeObject(forKey: Keys.address) as? String {
            self.address = address
        }

        if let parkId = aDecoder.decodeObject(forKey: Keys.parkId) as? String {
            self.parkId = parkId
        }

        if let photo = aDecoder.decodeObject(forKey: Keys.photo) as? UIImage {
            self.photo = photo
        }

        if let location = aDecoder.decodeObject(forKey: Keys.location) as? CLLocation {
            self.location = location
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(address, forKey: Keys.address)
        aCoder.encode(parkId, forKey: Keys.parkId)
        aCoder.encode(photo, forKey: Keys.photo)
        aCoder.encode(location, forKey: Keys.location)
    }
}
