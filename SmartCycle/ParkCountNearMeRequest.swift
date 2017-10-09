//
//  ParkCountNearMeRequest.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 19/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import ReachabilitySwift

class ParkCountNearMeRequest {
    typealias callbackBlock = ((_ count: String?, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(location: CLLocation, maxDistance: Float, userId: String, _ callback: @escaping (String?, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(nil, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@parking/listNearMeCount", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(nil, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let parameters = ["user_id": userId, "longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude, "minDistance": 0, "maxDistance": maxDistance] as [String: Any]

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue((UserManager.sharedInstance.user?.token)!, forHTTPHeaderField: "Authorization")        
        request.httpMethod = "POST"

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

            if let data = data, let count = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    callback(!count.isNumber ? "0" : count, nil)
                }
            } else {
                DispatchQueue.main.async {
                    callback("0", nil)
                }
            }
            
        }).resume()
    }
}
