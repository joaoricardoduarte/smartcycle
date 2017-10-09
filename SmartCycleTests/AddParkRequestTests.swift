//
//  AddParkRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class AddParkRequestTests: BaseTestCase {
    override func setUp() {
        super.setUp()

        loadParkB()
    }

    func testAddPark() {
        let request = AddParkRequest()

        let expectationA = expectation(description: "Add park service runs the callback closure")

        request.execute(parkItem: parkB!, userId: userId) { (parkId, error) in
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
