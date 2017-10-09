//
//  BaseTestCase.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 29/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import smartcycle

class BaseTestCase: XCTestCase {
    var user: User?
    var parkA: ParkItem?
    var parkB: ParkItem?
    var shop: StoreItem?
    var bikeA: BikeItem?
    var bikeB: BikeItem?
    var bikeC: BikeItem?
    let userId = "59a547cae82b6d000f8ec761"

    override func setUp() {
        super.setUp()

        loadUser()
        UserManager.sharedInstance.loadUser(user: user!)
    }

    override func tearDown() {
        resetAppData()

        super.tearDown()
    }

    func resetAppData() {
        UserDefaults.standard.removeObject(forKey: "UserData")
        UserDefaults.standard.synchronize()
    }

    func loadUser() {
        let jsonString = "{\"_id\":\"59a547cae82b6d000f8ec761\",\"token\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjU5YTU0N2NhZTgyYjZkMDAwZjhlYzc2MSIsImlhdCI6MTUwNDAwNDExMiwiZXhwIjoxNTA0MDkwNTEyfQ.pu0Q8n0asvhvACDmonVMTP8awd2CuNV2pYh7unN9QbQ\",\"bikes\":[{\"_id\":\"59a536a5ed4006000f2935c8\",\"brand\":\"Bicla\",\"type\":\"Road\",\"model\":\"Bmx\",\"primaryColor\":\"Green\",\"otherColor\":\"\",\"frameNumber\":\"\",\"photos\":null}],\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"test@test.com\"}"

        let jsonDict = Utils.convertToDictionary(text: jsonString)
        user = User(json: JSON(jsonDict as Any))
    }

    func loadParkA() {
        let jsonString = "{\"id\":\"999c12c0f4677b000ff3d69c\",\"smartcycle_park\":true,\"origin\":\"cycleStreets\",\"origin_id\":\"4535554\",\"user_id\":\"59a547cae82b6d000f8ec761\",\"capacity\":6,\"type\":\"Other\",\"geo\":[-0.13394,51.51094]}"
        let jsonDict = Utils.convertToDictionary(text: jsonString)
        parkA = ParkItem(json: JSON(jsonDict as Any))
    }

    func loadParkB() {
        let jsonString = "{\"origin_id\":\"4535554\",\"capacity\":6,\"type\":\"Wall bars\",\"geo\":[-0.13394,51.51094]}"
        let jsonDict = Utils.convertToDictionary(text: jsonString)
        parkB = ParkItem(json: JSON(jsonDict as Any))
    }

    func loadShop() {
        let jsonString = "{\"_id\":null,\"smartcycle_store\":false,\"origin\":\"cycleStreets\",\"origin_id\":\"3609589\",\"user_id\":null,\"name\":\"Rapha\",\"address\":{\"postcode\":null,\"streetAddress\":null},\"geo\":[-0.13671,51.51078]}"
        let jsonDict = Utils.convertToDictionary(text: jsonString)
        shop = StoreItem(json: JSON(jsonDict as Any))
    }

    func loadBikeA() {
        let jsonString = "{\"_id\":\"29a536a5ed4006000f2935c8\",\"brand\":\"Shimano\",\"type\":\"Road\",\"model\":\"Montanha\",\"primaryColor\":\"Black\",\"otherColor\":\"Brown\",\"frameNumber\":\"123456\",\"photos\":null}"
        let jsonDict = Utils.convertToDictionary(text: jsonString)
        bikeA = BikeItem(json: JSON(jsonDict as Any))
    }

    func loadBikeB() {
        let jsonString = "{\"_id\":\"39a536a5ed4006000f2935c8\",\"brand\":\"Bicla B\",\"type\":\"Road\",\"model\":\"BmxA\",\"primaryColor\":\"Yellow\",\"otherColor\":\"\",\"frameNumber\":\"\",\"photos\":null}"
        let jsonDict = Utils.convertToDictionary(text: jsonString)
        bikeB = BikeItem(json: JSON(jsonDict as Any))
    }

    func loadBikeC() {
        let jsonString = "{\"brand\":\"Bicla B\",\"type\":\"Road\",\"model\":\"BmxA\",\"primaryColor\":\"Yellow\",\"otherColor\":\"\",\"frameNumber\":\"\",\"photos\":null}"
        let jsonDict = Utils.convertToDictionary(text: jsonString)
        bikeC = BikeItem(json: JSON(jsonDict as Any))
    }
}
