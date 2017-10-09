//
//  LoginUITests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest

class LoginUITests: BaseUITestCase {

    func testLoginLogOut() {
        login(app: app)

        let homeScreen = app.otherElements["Home"]

        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: homeScreen, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        logout(app: app)

        let loginScreen = app.otherElements["Login"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loginScreen, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }

    func login(app: XCUIApplication) {
        app.buttons["LOGIN"].tap()

        var textField = app.textFields["E-mail"]
        textField.tap()
        textField.typeText("test@test.com")

        textField = app.secureTextFields["Password"]
        textField.tap()
        textField.typeText("123456")

        app.buttons["LOGIN"].tap()
    }

    func logout(app: XCUIApplication) {
        let profileButton = app.buttons["profile icon"]

        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: profileButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        profileButton.tap()
        app.buttons["LOGOUT"].tap()
        app.alerts["Log out"].buttons["OK"].tap()
    }
}
