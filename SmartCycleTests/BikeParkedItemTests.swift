//
//  BikeParkedItemTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
import CoreLocation
@testable import smartcycle

class BikeParkedItemTests: BaseTestCase {

    func testBikeParkedItem() {
        let bikeParkedItem = BikeParkedItem(address: "New street", parkId: "123456", photo: nil, location: CLLocation(latitude: 1.33, longitude: 0.53))

        XCTAssertTrue(bikeParkedItem.address == "New street")
        XCTAssertTrue(bikeParkedItem.parkId == "123456")
        XCTAssertNil(bikeParkedItem.photo)
        XCTAssertTrue(bikeParkedItem.location?.coordinate.latitude == 1.33)
    }
}
