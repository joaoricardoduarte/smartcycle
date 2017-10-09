//
//  ParkBikeRequest.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 14/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReachabilitySwift

class ParkBikeRequest {
    typealias callbackBlock = ((_ parkId: String?, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(userId: String, parkItem: ParkItem, _ callback: @escaping (String?, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(nil, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@bike/park", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(nil, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue((UserManager.sharedInstance.user?.token)!, forHTTPHeaderField: "Authorization")        
        request.httpMethod = "POST"

        var parameters = ["user_id": userId] as [String: Any]

        var parkParameters: [String: Any] = [:]

        if let capacity = Int(parkItem.capacity!), let parkType = parkItem.type, let location = parkItem.location, let originId = parkItem.originId {
            parkParameters = ["user_id": userId, "smartcycle_park": true, "origin": "SmartCycle", "origin_id": originId, "capacity": capacity, "type": parkType, "geo": [location.coordinate.longitude, location.coordinate.latitude]] as [String: Any]
        }

        parameters["park"] = parkParameters

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            callback(nil, NSError(domain:error.localizedDescription, code:111, userInfo:nil))
            return
        }

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let _ = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    callback(nil, NSError(domain:(error?.localizedDescription)!, code:111, userInfo:nil))
                }
                return
            }

            guard data != nil else {
                DispatchQueue.main.async {
                    callback(nil, NSError(domain:NSLocalizedString("Error: did not receive data", comment: ""), code:111, userInfo:nil))
                }
                return
            }

            //var backToString = String(data: data!, encoding: String.Encoding.utf8) as String!

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                    DispatchQueue.main.async {
                        callback(nil, NSError(domain:NSLocalizedString("Error trying to convert data to JSON", comment: ""), code:111, userInfo:nil))
                    }
                    return
                }

                let jsonString = JSON(json)
                if let opsDict = jsonString.dictionary!["ops"], let parkId = opsDict[0].dictionary?["park_id"]?.string {
                    DispatchQueue.main.async {
                        callback(parkId, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback(nil, NSError(domain:NSLocalizedString("Error: did not receive data", comment: ""), code:111, userInfo:nil))
                    }
                }

            } catch  {
                DispatchQueue.main.async {
                    callback(nil, NSError(domain:NSLocalizedString("Error trying to convert data to JSON", comment: ""), code:111, userInfo:nil))
                }
                return
            }
            
        }).resume()
    }
}
