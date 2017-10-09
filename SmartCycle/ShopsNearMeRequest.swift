//
//  ShopsNearMeRequest.swift
//  SmartCycle
//
//  Created by Joao Duarte on 24/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import ReachabilitySwift

class ShopsNearMeRequest {
    typealias callbackBlock = ((_ results: [StoreItem]?, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(location: CLLocation, radius: Float, userId: String, _ callback: @escaping ([StoreItem]?, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(nil, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@stores/listNearMe", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(nil, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let parameters = ["user_id": userId, "longitude": location.coordinate.longitude, "latitude": location.coordinate.latitude, "radius": radius] as [String: Any]

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

            //var backToString = String(data: data!, encoding: String.Encoding.utf8) as String!

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: AnyObject]] else {
                    DispatchQueue.main.async {
                        callback(nil, NSError(domain:NSLocalizedString("Error trying to convert data to JSON", comment: ""), code:111, userInfo:nil))
                    }
                    return
                }

                let jsonResponse = JSON(json)
                var results: [StoreItem] = []

                for subJson in jsonResponse.array! {
                    let item = StoreItem(json: subJson)
                    results.append(item)
                }

                DispatchQueue.main.async {
                    callback(results, nil)
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
