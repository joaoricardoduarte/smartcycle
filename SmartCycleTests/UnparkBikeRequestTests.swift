//
//  UnparkBikeRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
import CoreLocation
@testable import smartcycle

class UnparkBikeRequestTests: BaseTestCase {
    var parkId: String?

    override func setUp() {
        super.setUp()

        loadParkB()
        parkB?.originId = "1234563"
        parkB?.location = CLLocation(latitude: -1.453, longitude: 0.432)

        addPark()
        parkBike()
    }

    private func addPark() {
        let request = AddParkRequest()

        let expectationA = expectation(description: "Add park service runs the callback closure")

        request.execute(parkItem: parkB!, userId: userId) { (parkId, error) in
            XCTAssertNotNil(parkId)
            self.parkId = parkId

            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }

    private func parkBike() {
        let request = ParkBikeRequest()

        let expectationA = expectation(description: "Park bike service runs the callback closure")

        parkB?.parkId = self.parkId
        request.execute(userId: userId, parkItem: parkB!) { (parkId, error) in
            XCTAssertNotNil(parkId)
            
            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }

    func testUnparkBike() {
        let request = UnParkBikeRequest()

        let expectationA = expectation(description: "Unpark bike service runs the callback closure")
        if let parkId = parkId {
            request.execute(userId: userId, parkId: parkId) { (success, error) in
                XCTAssertTrue(success)

                expectationA.fulfill()
            }

            waitForExpectations(timeout: 30) { error in
                if let error = error {
                    XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
                }
            }
        }
    }
}
