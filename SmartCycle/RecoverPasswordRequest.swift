//
//  RecoverPasswordRequest.swift
//  SmartCycle
//
//  Created by Joao Duarte on 03/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import ReachabilitySwift

class RecoverPasswordRequest {
    typealias callbackBlock = ((_ success: Bool, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(email: String, _ callback: @escaping (Bool, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(false, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@users/recoverPassword", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(false, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let parameters = ["email": email] as [String: Any]

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
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
