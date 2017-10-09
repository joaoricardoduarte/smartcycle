//
//  SignUpRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class SignUpRequestTests: BaseTestCase {

    func testSignUp() {
        let request = SignUpRequest()

        let expectationA = expectation(description: "Sign up service runs the callback closure")

        request.execute(email: "test@test.com", password: "123456", firstName: "Test", lastName: "User") { (success, error) in
            XCTAssertTrue(success, "Sign up not successfull")

            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }
}
