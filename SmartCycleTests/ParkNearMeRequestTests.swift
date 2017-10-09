//
//  ParkNearMeRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
import CoreLocation
@testable import smartcycle

class ParkNearMeRequestTests: BaseTestCase {

    func testParkNearMe() {
        let request = ParkNearMeRequest()

        let expectationA = expectation(description: "Parks Near Me service runs the callback closure")

        request.execute(location: CLLocation(latitude: 51.51094, longitude: -0.13394), radius: 1, userId: userId) { (results, error) in
            XCTAssertTrue((results?.count)! > 0, "Parks near me not successfull")

            expectationA.fulfill()
        }
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }
}
