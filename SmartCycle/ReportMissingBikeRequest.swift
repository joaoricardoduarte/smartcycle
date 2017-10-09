//
//  ReportMissingBikeRequest.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 28/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import ReachabilitySwift

class ReportMissingBikeRequest {
    typealias callbackBlock = ((_ sucess: Bool, _ error: Error?) -> Void)

    fileprivate var callback: callbackBlock?
    let reachability = Reachability()!

    func execute(parkingId: String, userId: String, bikeId: String, location: CLLocation, _ callback: @escaping (Bool, Error?) -> Void) {
        self.callback = callback

        if !reachability.isReachable  {
            callback(false, NSError(domain:NSLocalizedString("Error: Please check your internet connection.", comment: ""), code:111, userInfo:nil))
            return
        }

        let serviceUrl = String(format:"%@report/bike/missing", Constants.Urls.SmartcycleAPIUrl)

        guard let url = URL(string: serviceUrl) else {
            callback(false, NSError(domain:NSLocalizedString("Error: cannot create URL", comment: ""), code:111, userInfo:nil))
            return
        }

        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue((UserManager.sharedInstance.user?.token)!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let parameters = ["parking_id": parkingId, "user_id": userId, "bike_id": bikeId, "agreeShareBikeDetails": true, "geo": [location.coordinate.longitude, location.coordinate.latitude]] as [String: Any]

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
            if status == 200 {
                DispatchQueue.main.async {
                    callback(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    callback(false, NSError(domain:NSLocalizedString("Error: Operation not successfull", comment: ""), code:status, userInfo:nil))
                }
            }

        }).resume()
    }
}
