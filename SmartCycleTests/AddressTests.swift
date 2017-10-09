//
//  AddressTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class AddressTests: BaseTestCase {

    func testFullAddress() {
        let address = Address()
        address.addressNumber = "10"
        address.addressStreet = "New Street"
        address.postCode = "SW6 6RE"
        address.city = "London"

        let fullAddress = address.fullAddress()
        XCTAssert(fullAddress == "10 New Street, Sw6 6Re, London", "Address not matching")
    }
}
