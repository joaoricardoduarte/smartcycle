//
//  ParkBikeRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class ParkBikeRequestTests: BaseTestCase {
    
    override func setUp() {
        super.setUp()

        loadParkA()
    }

    func testParkBike() {
        let request = ParkBikeRequest()

        let expectationA = expectation(description: "Park bike service runs the callback closure")

        request.execute(userId: userId, parkItem: parkA!) { (parkId, error) in
            XCTAssertNotNil(parkId)

            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }
}
