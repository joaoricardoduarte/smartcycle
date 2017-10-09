//
//  ShopItemTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
import CoreLocation
@testable import smartcycle

class ShopItemTests: BaseTestCase {
    override func setUp() {
        super.setUp()

        loadShop()
    }

    func testShopItem() {
        XCTAssertTrue(shop?.isSmartcycleShop == false)
        XCTAssertTrue(shop?.originId == "3609589")
        XCTAssertTrue(shop?.name == "Rapha")
        XCTAssertTrue(shop?.location?.coordinate.longitude == -0.13671)
    }
}
