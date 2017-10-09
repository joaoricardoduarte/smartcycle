//
//  UtilsTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class UtilsTests: BaseTestCase {

    func testValidEmail() {
        var email = "joao@duarte.com"
        XCTAssertTrue(Utils.isValidEmail(email: email))

        email = "sasadsd"
        XCTAssertFalse(Utils.isValidEmail(email: email))
    }

    func testConvertToDictionary() {
        let string = "{\"_id\":\"59a547cae82b6d000f8ec761\",\"token\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjU5OWMxMmMwZjQ2NzdiMDAwZmYzZDY5YyIsImlhdCI6MTUwMzQwODYyMywiZXhwIjoxNTAzNDk1MDIzfQ.c2Ku71vDo1ESqhm3q9EHufdixUFcSJddiCi5RBGN56c\",\"firstName\":\"Joao\",\"lastName\":\"Duarte\",\"email\":\"joaoricardoduarte@gmail.com\"}"
        let dict = Utils.convertToDictionary(text: string)

        XCTAssertTrue(dict!["_id"] as! String == "59a547cae82b6d000f8ec761")
    }

}
