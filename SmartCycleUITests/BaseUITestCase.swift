//
//  BaseUITestCase.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 30/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest

class BaseUITestCase: XCTestCase {
    internal let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app.launchArguments += ["UI-Testing"]
        app.launch()
    }
}
