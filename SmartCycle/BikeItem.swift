//
//  BikeItem.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 27/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import SwiftyJSON

class BikeItem: NSObject, NSCoding {
    var bikeId: String?
    var brand: String?
    var type: String?
    var model: String?
    var primaryColor: String?
    var otherColor: String?
    var frameNumber: String?
    var photoCloudinaryId: String?
    var photo: UIImage?

    struct Keys {
        static let bikeId = "bikeId"
        static let brand = "brand"
        static let type = "type"
        static let model = "model"
        static let primaryColor = "primaryColor"
        static let otherColor = "otherColor"
        static let frameNumber = "frameNumber"
        static let photoCloudinaryId = "photoCloudinaryId"
        static let photo = "photo"
    }

    override init() {

    }

    init(json: JSON) {
        bikeId = json.dictionary!["_id"]?.string ?? ""
        brand = json.dictionary!["brand"]?.string ?? ""
        type = json.dictionary!["type"]?.string ?? ""
        model = json.dictionary!["model"]?.string ?? ""
        primaryColor = json.dictionary!["primaryColor"]?.string ?? ""
        otherColor = json.dictionary!["otherColor"]?.string ?? ""
        frameNumber = json.dictionary!["frameNumber"]?.string ?? ""

        if let photosArray = json.dictionary!["photos"]?.array {
            if photosArray.count > 0 {
                photoCloudinaryId = photosArray[0].string
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        if let bikeId = aDecoder.decodeObject(forKey: Keys.bikeId) as? String {
            self.bikeId = bikeId
        }

        if let brand = aDecoder.decodeObject(forKey: Keys.brand) as? String {
            self.brand = brand
        }

        if let type = aDecoder.decodeObject(forKey: Keys.type) as? String {
            self.type = type
        }

        if let model = aDecoder.decodeObject(forKey: Keys.model) as? String {
            self.model = model
        }

        if let primaryColor = aDecoder.decodeObject(forKey: Keys.primaryColor) as? String {
            self.primaryColor = primaryColor
        }

        if let otherColor = aDecoder.decodeObject(forKey: Keys.otherColor) as? String {
            self.otherColor = otherColor
        }

        if let frameNumber = aDecoder.decodeObject(forKey: Keys.frameNumber) as? String {
            self.frameNumber = frameNumber
        }

        if let photoCloudinaryId = aDecoder.decodeObject(forKey: Keys.photoCloudinaryId) as? String {
            self.photoCloudinaryId = photoCloudinaryId
        }

        if let photo = aDecoder.decodeObject(forKey: Keys.photo) as? UIImage {
            self.photo = photo
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(bikeId, forKey: Keys.bikeId)
        aCoder.encode(brand, forKey: Keys.brand)
        aCoder.encode(type, forKey: Keys.type)
        aCoder.encode(model, forKey: Keys.model)
        aCoder.encode(primaryColor, forKey: Keys.primaryColor)
        aCoder.encode(otherColor, forKey: Keys.otherColor)
        aCoder.encode(frameNumber, forKey: Keys.frameNumber)
        aCoder.encode(photoCloudinaryId, forKey: Keys.photoCloudinaryId)
        aCoder.encode(photo, forKey: Keys.photo)
    }
}

// MARK: - Equatable Protocol
func == (lhs: BikeItem, rhs: BikeItem) -> Bool {
    if let bikeIdA = lhs.bikeId, let bikeIdB = rhs.bikeId {
        return bikeIdA == bikeIdB
    }

    return false
}
