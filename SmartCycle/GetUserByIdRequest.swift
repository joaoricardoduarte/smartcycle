//
//  GetUserByIdRequest.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 29/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReachabilitySwift

class GetUserByIdRequest {
    typealias callbackBlock = ((_ results: User?, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(userId: String, _ callback: @escaping (User?, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(nil, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@users/getUserById", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(nil, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let parameters = ["id": userId] as [String: Any]

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(Constants.UserDefaults.SmartCycleToken, forHTTPHeaderField: "Authorization")
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

            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                    DispatchQueue.main.async {
                        callback(nil, NSError(domain:NSLocalizedString("Error trying to convert data to JSON", comment: ""), code:111, userInfo:nil))
                    }
                    return
                }

                let user = User(json: JSON(json))
                DispatchQueue.main.async {
                    callback(user, nil)
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
