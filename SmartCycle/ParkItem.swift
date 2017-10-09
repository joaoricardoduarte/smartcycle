//
//  ParkItem.swift
//  SmartCycle
//
//  Created by Joao Duarte on 24/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import SwiftyJSON
import CoreLocation

class ParkItem {
    var parkId: String?
    var originId: String?
    var capacity: String?
    var type: String?
    var location: CLLocation?
    var address: Address?
    var parkCloudinaryPhotoId: String?
    var isSmartcyclePark = false

    init(location: CLLocation) {
        self.location = location
    }

    init(json: JSON) {
        parkId = json.dictionary!["id"]?.string ?? ""
        isSmartcyclePark = json.dictionary!["smartcycle_park"]?.bool ?? false
        let parkCapacity = json.dictionary!["capacity"]?.int ?? 5
        capacity = String(parkCapacity)
        type = json.dictionary!["type"]?.string ?? NSLocalizedString("Other", comment: "")
        originId = json.dictionary!["origin_id"]?.string ?? nil

        if let photos = json.dictionary?["photos"]?.array {
            if photos.count > 0 {
                parkCloudinaryPhotoId = photos[0].rawString()
            }
        }

        let geo = json.dictionary!["geo"]?.arrayObject
        if let latitude = geo?[1] as? CLLocationDegrees, let longitude = geo?[0] as? CLLocationDegrees {
            location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}
