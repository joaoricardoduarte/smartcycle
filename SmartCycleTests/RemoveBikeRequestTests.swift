//
//  RemoveBikeRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class RemoveBikeRequestTests: BaseTestCase {
    var addedBikeId: String?
    
    override func setUp() {
        super.setUp()

        loadBikeC()
        addBikeToBeLaterRemoved()
    }

    func addBikeToBeLaterRemoved() {
        let request = AddBikeRequest()

        let expectationA = expectation(description: "Add bike service runs the callback closure")

        request.execute(bikeItem: bikeC!, userId: userId) { (bikeId, error) in
            XCTAssertNotNil(bikeId)
            self.addedBikeId = bikeId

            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }
    
    func testRemoveBike() {
        let request = RemoveBikeRequest()

        let expectationA = expectation(description: "Remove bike service runs the callback closure")

        if let bikeId = addedBikeId {
            request.execute(bikeId: bikeId, userId: userId) { (success, error) in
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
