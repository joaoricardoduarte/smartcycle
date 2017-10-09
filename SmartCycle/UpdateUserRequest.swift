//
//  UpdateUserRequest.swift
//  SmartCycle
//
//  Created by Joao Duarte on 19/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReachabilitySwift

class UpdateUserRequest {
    typealias callbackBlock = ((_ success: Bool, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(user: User, _ callback: @escaping (Bool, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(false, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@users/update", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(false, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let address1 = user.address ?? ""
        let city = user.city ?? ""
        let country = user.country ?? ""
        let postCode = user.postCode ?? ""
        let phoneNumber = user.phoneNumber ?? ""
        let twitter = user.twitter ?? ""
        let gender = user.gender ?? nil
        var birthdate: String?
        let photo = user.profileCloudinaryPhotoId ?? nil

        if let birthDate = user.dateOfBirth {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constants.DateFormat.SimpleDateReverseFormat
            birthdate = dateFormatter.string(from: birthDate)
        }

        var parameters = ["_id": user.userId, "firstName": user.firstName, "lastName": user.lastName, "address1": address1, "townCity": city, "country": country, "postalCode": postCode, "phoneNumber": phoneNumber, "twitter": twitter] as [String: Any]

        if let birthdate = birthdate {
            parameters["birthDate"] = birthdate
        }

        if let photo = photo {
            parameters["photo"] = photo
        }

        if let gender = gender {
            parameters["gender"] = gender
        }

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue((UserManager.sharedInstance.user?.token)!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            callback(false, NSError(domain:error.localizedDescription, code:111, userInfo:nil))
            return
        }

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let _ = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in

            guard error == nil else {
                DispatchQueue.main.async {
                    callback(false, NSError(domain:(error?.localizedDescription)!, code:111, userInfo:nil))
                }
                return
            }

            guard data != nil else {
                DispatchQueue.main.async {
                    callback(false, NSError(domain:NSLocalizedString("Error: did not receive data", comment: ""), code:111, userInfo:nil))
                }
                return
            }

            let status = (response as! HTTPURLResponse).statusCode

            DispatchQueue.main.async {
                callback(status == 204 ? true : false, nil)
            }

        }).resume()
    }
}
