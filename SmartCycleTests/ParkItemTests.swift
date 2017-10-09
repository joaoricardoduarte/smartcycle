//
//  ParkItemTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
import CoreLocation
@testable import smartcycle

class ParkItemTests: BaseTestCase {

    override func setUp() {
        super.setUp()

        loadParkA()
    }

    func testparkItem() {
        XCTAssertTrue(parkA?.parkId == "999c12c0f4677b000ff3d69c")
        XCTAssertTrue(parkA?.originId == "4535554")
        XCTAssertTrue(parkA?.capacity == "6")
        XCTAssertTrue(parkA?.type == "Other")
        XCTAssertTrue(parkA?.isSmartcyclePark == true)
        XCTAssertTrue(parkA?.location?.coordinate.longitude == -0.13394)
    }
}
