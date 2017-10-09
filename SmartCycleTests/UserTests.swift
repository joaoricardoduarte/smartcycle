//
//  UserTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class UserTests: BaseTestCase {

    func testUserDetails() {
        XCTAssertTrue(user?.email == "test@test.com")
        XCTAssertTrue(user?.firstName == "Test")
        XCTAssertTrue(user?.lastName == "User")
    }

    func testUserBikesCount() {
        XCTAssertTrue(user?.bikes.count == 1)
    }
}
