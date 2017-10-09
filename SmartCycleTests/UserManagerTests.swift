//
//  UserManagerTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class UserManagerTests: BaseTestCase {
    
    override func setUp() {
        super.setUp()

        loadBikeA()
        loadBikeB()
    }

    func testLoadUser() {
        UserManager.sharedInstance.loadUser(user: user!)
        XCTAssertTrue(user?.firstName == "Test")
    }

    func testLoadUserFromDefaults() {
        UserManager.sharedInstance.loadUser(user: user!)

        UserManager.sharedInstance.user = nil

        UserManager.sharedInstance.loadUser()

        XCTAssertTrue(UserManager.sharedInstance.user?.firstName == "Test")
    }

    func testSaveUser() {
        UserManager.sharedInstance.loadUser(user: user!)
        UserManager.sharedInstance.saveUser()

        UserManager.sharedInstance.user = nil
        UserManager.sharedInstance.loadUser()

        XCTAssertTrue(UserManager.sharedInstance.user?.firstName == "Test")
    }

    func testClearUser() {
        UserManager.sharedInstance.loadUser(user: user!)
        UserManager.sharedInstance.clearUser()

        XCTAssertNil(UserManager.sharedInstance.user)
    }

    func testAddBike() {
        UserManager.sharedInstance.loadUser(user: user!)

        UserManager.sharedInstance.addBike(item: bikeA!)
        UserManager.sharedInstance.addBike(item: bikeB!)

        XCTAssertTrue(UserManager.sharedInstance.user?.bikes.count == 3)
    }

    func testEditBike() {
        UserManager.sharedInstance.loadUser(user: user!)

        let bike = UserManager.sharedInstance.user?.bikes[0]

        UserManager.sharedInstance.editBike(oldBike: bike!, newBike: bikeB!)

        XCTAssertTrue(UserManager.sharedInstance.user?.bikes[0].brand == "Bicla B")
    }

    func testRemoveBike() {
        UserManager.sharedInstance.loadUser(user: user!)

        UserManager.sharedInstance.addBike(item: bikeA!)
        UserManager.sharedInstance.addBike(item: bikeB!)

        UserManager.sharedInstance.removeBike(item: bikeB!)

        XCTAssertTrue(UserManager.sharedInstance.user?.bikes.count == 2)
    }
}
