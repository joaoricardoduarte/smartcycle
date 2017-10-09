//
//  User.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 28/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

//63812030-7201-11e7-8fae-97d25dcc629a

import Foundation
import SwiftyJSON

class User: NSObject, NSCoding {
    var userId: String
    var email: String
    var firstName: String
    var lastName: String
    var token: String
    var profileImage: UIImage?
    var profileCloudinaryPhotoId: String?
    var profileCloudinaryVersion: String?
    var address: String?
    var city: String?
    var postCode: String?
    var country: String?
    var phoneNumber: String?
    var twitter: String?
    var gender: String?
    var dateOfBirth: Date?
    var bikes: [BikeItem] = []

    struct Keys {
        static let userId = "userId"
        static let email = "email"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let token = "token"
        static let profileImage = "profileImage"
        static let profileCloudinaryPhotoId = "profileCloudinaryPhotoId"
        static let profileCloudinaryVersion = "profileCloudinaryVersion"
        static let address = "address"
        static let city = "city"
        static let postCode = "postCode"
        static let country = "country"
        static let phoneNumber = "phoneNumber"
        static let gender = "gender"
        static let dateOfBirth = "dateOfBirth"
        static let bikes = "bikes"
        static let twitter = "twitter"
    }

    init(json: JSON) {
        userId = json.dictionary!["_id"]?.string ?? ""
        email = json.dictionary!["email"]?.string ?? ""
        firstName = json.dictionary!["firstName"]?.string ?? ""
        lastName = json.dictionary!["lastName"]?.string ?? ""
        token = json.dictionary!["token"]?.string ?? ""

        phoneNumber = json.dictionary!["phoneNumber"]?.string ?? ""
        gender = json.dictionary!["gender"]?.string ?? ""
        city = json.dictionary!["townCity"]?.string ?? ""
        country = json.dictionary!["country"]?.string ?? ""
        twitter = json.dictionary!["twitter"]?.string ?? ""

        let birthDate = json.dictionary!["birthDate"]?.string ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DateFormat.SimpleDateFormat
        dateOfBirth = dateFormatter.date(from: birthDate)

        if let bikesArray = json.dictionary!["bikes"]?.array {
            for item in bikesArray {
                let bike = BikeItem(json: item)
                bikes.append(bike)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.userId = aDecoder.decodeObject(forKey: Keys.userId) as? String ?? ""
        self.email = aDecoder.decodeObject(forKey: Keys.email) as? String ?? ""
        self.firstName = aDecoder.decodeObject(forKey: Keys.firstName) as? String ?? ""
        self.lastName = aDecoder.decodeObject(forKey: Keys.lastName) as? String ?? ""
        self.token = aDecoder.decodeObject(forKey: Keys.token) as? String ?? ""

        if let profileImage = aDecoder.decodeObject(forKey: Keys.profileImage) as? UIImage {
            self.profileImage = profileImage
        }

        if let profileCloudinaryPhotoId = aDecoder.decodeObject(forKey: Keys.profileCloudinaryPhotoId) as? String {
            self.profileCloudinaryPhotoId = profileCloudinaryPhotoId
        }

        if let profileCloudinaryVersion = aDecoder.decodeObject(forKey: Keys.profileCloudinaryVersion) as? String {
            self.profileCloudinaryVersion = profileCloudinaryVersion
        }

        if let twitter = aDecoder.decodeObject(forKey: Keys.twitter) as? String {
            self.twitter = twitter
        }

        if let address = aDecoder.decodeObject(forKey: Keys.address) as? String {
            self.address = address
        }

        if let city = aDecoder.decodeObject(forKey: Keys.city) as? String {
            self.city = city
        }

        if let postCode = aDecoder.decodeObject(forKey: Keys.postCode) as? String {
            self.postCode = postCode
        }

        if let country = aDecoder.decodeObject(forKey: Keys.country) as? String {
            self.country = country
        }

        if let phoneNumber = aDecoder.decodeObject(forKey: Keys.phoneNumber) as? String {
            self.phoneNumber = phoneNumber
        }

        if let gender = aDecoder.decodeObject(forKey: Keys.gender) as? String {
            self.gender = gender
        }

        if let dateOfBirth = aDecoder.decodeObject(forKey: Keys.dateOfBirth) as? Date {
            self.dateOfBirth = dateOfBirth
        }

        if let bikes = aDecoder.decodeObject(forKey: Keys.bikes) as? [BikeItem] {
            self.bikes = bikes
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(userId, forKey: Keys.userId)
        aCoder.encode(email, forKey: Keys.email)
        aCoder.encode(firstName, forKey: Keys.firstName)
        aCoder.encode(lastName, forKey: Keys.lastName)
        aCoder.encode(token, forKey: Keys.token)
        aCoder.encode(profileImage, forKey: Keys.profileImage)
        aCoder.encode(profileCloudinaryPhotoId, forKey: Keys.profileCloudinaryPhotoId)
        aCoder.encode(profileCloudinaryVersion, forKey: Keys.profileCloudinaryVersion)
        aCoder.encode(twitter, forKey: Keys.twitter)
        aCoder.encode(address, forKey: Keys.address)
        aCoder.encode(city, forKey: Keys.city)
        aCoder.encode(postCode, forKey: Keys.postCode)
        aCoder.encode(country, forKey: Keys.country)
        aCoder.encode(phoneNumber, forKey: Keys.phoneNumber)
        aCoder.encode(gender, forKey: Keys.gender)
        aCoder.encode(dateOfBirth, forKey: Keys.dateOfBirth)
        aCoder.encode(bikes, forKey: Keys.bikes)
    }
}
