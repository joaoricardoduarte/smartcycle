//
//  BrandingTests.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 22/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
@testable import smartcycle

class BrandingTests: BaseTestCase {
    
    func testFontMediumSize() {
        let font = Branding.fontMediumForSize(15)
        XCTAssertTrue(font.pointSize == 15)
        XCTAssertTrue(font.fontName == "Helvetica")
    }

    func testmakeImageRounded() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.green.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageView = UIImageView(image: img)
        Branding.makeImageRounded(image: imageView)

        XCTAssertTrue(imageView.layer.cornerRadius == 5)
        XCTAssertTrue(imageView.layer.borderWidth == 0)
        XCTAssertTrue(imageView.layer.borderColor == UIColor.clear.cgColor)
    }
}
