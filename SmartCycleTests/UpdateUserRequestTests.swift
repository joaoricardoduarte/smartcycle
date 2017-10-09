//
//  UpdateUserRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class UpdateUserRequestTests: BaseTestCase {

    override func setUp() {
        super.setUp()

        user?.phoneNumber = "123456786"
    }

    func testUpdateUser() {
        let request = UpdateUserRequest()

        let expectationA = expectation(description: "Update user service runs the callback closure")

        request.execute(user: user!) { (success, error) in
            XCTAssertTrue(success, "Update user not successfull")

            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }
}
