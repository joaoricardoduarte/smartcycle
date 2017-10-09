//
//  UserManager.swift
//  SmartCycle
//
//  Created by Joao Duarte on 09/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

class UserManager {

    // MARK: - Shared Instance
    static let sharedInstance = UserManager()

    var user: User?

    private init() {
        loadUser()
    }

    internal func loadUser() {
        if let data = UserDefaults.standard.object(forKey: Constants.UserDefaults.UserData) as? Data {
            let unarc = NSKeyedUnarchiver(forReadingWith: data)
            unarc.setClass(User.self, forClassName: "User")
            if let user = unarc.decodeObject(forKey: "root") as? User {
                self.user = user
            }
        }
    }

    internal func saveUser() {
        if let user = user {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: user), forKey: Constants.UserDefaults.UserData)
            UserDefaults.standard.synchronize()
        }
    }

    func loadUser(user: User) {
        self.user = user

        saveUser()
    }

    func clearUser() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.UserData)
        UserDefaults.standard.synchronize()
        self.user = nil
    }

    // MARK: - Bikes
    func addBike(item: BikeItem) {
        if var bikes = user?.bikes {
            bikes.append(item)

            user?.bikes = bikes
            saveUser()
        }
    }

    func editBike(oldBike: BikeItem, newBike: BikeItem) {
        if var bikes = user?.bikes {
            for (index, item) in bikes.enumerated() {
                if item == oldBike {
                    bikes[index] = newBike
                }

                break
            }

            user?.bikes = bikes
            saveUser()
        }
    }

    func removeBike(item: BikeItem) {
        if var bikes = user?.bikes {
            for (index, bike) in bikes.enumerated() {
                if bike == item {
                    bikes.remove(at: index)

                    break
                }
            }

            user?.bikes = bikes
            saveUser()
        }
    }
}
