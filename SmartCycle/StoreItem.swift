//
//  StoreItem.swift
//  SmartCycle
//
//  Created by Joao Duarte on 24/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import SwiftyJSON
import CoreLocation

class StoreItem {
    var storeId: String?
    var name: String?
    var location: CLLocation?
    var isSmartcycleShop = false
    var address = Address()
    var originId: String?
    var company: String?
    var website: String?
    var telephone: String?
    var openingHours: [[String: String]] = []

    init(json: JSON) {
        storeId = json.dictionary!["_id"]?.string ?? nil
        name = json.dictionary!["name"]?.string ?? ""
        isSmartcycleShop = json.dictionary!["smartcycle_store"]?.bool ?? false
        originId = json.dictionary!["origin_id"]?.string ?? nil
        
//        let openingHoursDict = json.dictionary!["openingHours"]?.dictionary
//        var hoursArray: [[String: String]] = []
//
//        for weekdayKey in (openingHoursDict?.keys)! {
//            if let hoursDict = openingHoursDict?[weekdayKey]?.dictionary {
//                if let open = hoursDict["opens"]?.string, let closes = hoursDict["closes"]?.string {
//                    let openString = String(open.characters.dropLast(3))
//                    let closeString = String(closes.characters.dropLast(3))
//
//                    let hours = [weekdayKey : "\(openString) - \(closeString)"]
//                    hoursArray.append(hours)
//                } else {
//                    let hoursNotavailable = [weekdayKey : NSLocalizedString("Not available", comment: "")]
//                    hoursArray.append(hoursNotavailable)
//                }
//            }
//        }
//
//        sortHoursArray(unorderedArray: hoursArray)

        let geo = json.dictionary!["geo"]?.arrayObject
        if let latitude = geo?[1] as? CLLocationDegrees, let longitude = geo?[0] as? CLLocationDegrees {
            location = CLLocation(latitude: latitude, longitude: longitude)
        }

        let addressDict = json.dictionary?["address"]
        address.addressStreet = addressDict?.dictionary!["streetAddress"]?.string ?? ""
        address.postCode = addressDict?.dictionary!["postalCode"]?.string ?? ""
    }

//    fileprivate func sortHoursArray(unorderedArray: [[String: String]]) {
//        // This is very dodgy. Need to make something more elegant
//        for itemDict in unorderedArray {
//            if let _ = itemDict["monday"] {
//                openingHours.append(itemDict)
//            }
//        }
//
//        for itemDict in unorderedArray {
//            if let _ = itemDict["tuesday"] {
//                openingHours.append(itemDict)
//            }
//        }
//
//        for itemDict in unorderedArray {
//            if let _ = itemDict["wednesday"] {
//                openingHours.append(itemDict)
//            }
//        }
//
//        for itemDict in unorderedArray {
//            if let _ = itemDict["thursday"] {
//                openingHours.append(itemDict)
//            }
//        }
//
//        for itemDict in unorderedArray {
//            if let _ = itemDict["friday"] {
//                openingHours.append(itemDict)
//            }
//        }
//
//        for itemDict in unorderedArray {
//            if let _ = itemDict["saturday"] {
//                openingHours.append(itemDict)
//            }
//        }
//
//        for itemDict in unorderedArray {
//            if let _ = itemDict["sunday"] {
//                openingHours.append(itemDict)
//            }
//        }
//    }
}
