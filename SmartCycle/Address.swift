//
//  Address.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 25/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation

class Address {
    var addressStreet: String?
    var addressNumber: String?
    var postCode: String?
    var city: String?
    var country: String?

    func fullAddress() -> String {
        var fullString = ""
        if let addressNumber = addressNumber, addressNumber.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            fullString.append(addressNumber.capitalized)
        }

        if let addressStreet = addressStreet,  addressStreet.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            fullString.append(String(format:" %@", addressStreet.capitalized))
        }

        if let postCode = postCode, postCode.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            fullString.append(String(format:", %@", postCode.capitalized))
        }

        if let city = city, city.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            fullString.append(String(format:", %@", city.capitalized))
        }

        return fullString
    }
}
