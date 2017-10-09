//
//  LoginRequestTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class LoginRequestTests: BaseTestCase {

    func testSuccessLogin() {
        let request = LoginRequest()

        let expectationA = expectation(description: "Login service runs the callback closure")

        request.execute(email: "test@test.com", password: "123456") { (userA, error) in
            XCTAssertTrue(userA?.firstName == "Test", "Login not successfull")

            expectationA.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("waitFOrExpectationsWithTimeout erroed: \(error)")
            }
        }
    }
    
}
