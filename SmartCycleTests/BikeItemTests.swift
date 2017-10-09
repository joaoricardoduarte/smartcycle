//
//  BikeItemTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class BikeItemTests: BaseTestCase {
    override func setUp() {
        super.setUp()

        loadBikeA()
    }

    func testBikeItem() {
        XCTAssertTrue(bikeA?.bikeId == "29a536a5ed4006000f2935c8")
        XCTAssertTrue(bikeA?.brand == "Shimano")
        XCTAssertTrue(bikeA?.type == "Road")
        XCTAssertTrue(bikeA?.model == "Montanha")
        XCTAssertTrue(bikeA?.primaryColor == "Black")
        XCTAssertTrue(bikeA?.otherColor == "Brown")
        XCTAssertTrue(bikeA?.frameNumber == "123456")
    }
}
