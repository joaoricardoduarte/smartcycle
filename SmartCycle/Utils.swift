//
//  Utils.swift
//  SmartCycle
//
//  Created by Joao Duarte on 28/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import Cloudinary
import CoreLocation

class Utils {
    class func uploadToCloudinary(cloudinary: CLDCloudinary, image: UIImage, folder: String, publicId: String? = nil, completionHandler: @escaping (_ publicId: String?, _ version: String?) -> Void) {
        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

        if let data = UIImageJPEGRepresentation(image, 0.3) {
            let params = CLDUploadRequestParams()
            _ = params.setFolder(folder)

            if let publicId = publicId {
                let uploadPreset = "ojzew8iu"
                let timestamp = UInt64(Date().timeIntervalSince1970)
                let signatureString = "folder=\(folder)&" + "invalidate=1&" + "public_id=\(publicId)&" + "timestamp=\(timestamp)&" + "upload_preset=\(uploadPreset)\(Constants.Keys.CloudinarySecret)"

                let signature = CLDSignature(signature: signatureString.sha1(), timestamp: NSNumber(value: timestamp))
                params.setPublicId(publicId)
                params.setParam("api_key", value: Constants.Keys.CloudinaryAPIKey)
                params.setParam("timestamp", value: timestamp)
                params.setSignature(signature)
                params.setInvalidate(true)
                params.setUploadPreset(uploadPreset)

                cloudinary.createUploader().signedUpload(data: data, params: params, progress: { (progress) in
                }, completionHandler: { (result, error) in
                    LoadingOverlay.shared.hideOverlayView()
                    if let error = error {
                        print("Error uploading image %@", error)
                        completionHandler(nil, nil)
                    } else {
                        if let publicId = result?.publicId, let version = result?.version {
                            completionHandler(publicId, version)
                        }
                    }
                })
            } else {
                cloudinary.createUploader().upload(data: data, uploadPreset: "uanmgkb9", params: params, progress: { (progress) in
                }, completionHandler: { (result, error) in
                    LoadingOverlay.shared.hideOverlayView()
                    if let error = error {
                        print("Error uploading image %@", error)
                        completionHandler(nil, nil)
                    } else {
                        if let publicId = result?.publicId, let version = result?.version {
                            completionHandler(publicId, version)
                        }
                    }
                })
            }
        }
    }

    class func loadCloudinaryImage(cloudinary: CLDCloudinary, publicId: String, version: String? = nil, imageView: UIImageView) {
        let transformation = CLDTransformation().setWidth(Int(imageView.frame.width)).setHeight(Int(imageView.frame.height)).setCrop(.fill).setFetchFormat("auto")

        if var url = cloudinary.createUrl().setTransformation(transformation).generate(publicId) {

            if let version = version {
                url = cloudinary.createUrl().setTransformation(transformation).setVersion(version).generate(publicId)!
            }

            cloudinary.createDownloader().fetchImage(url, { (progress) in }, completionHandler: {(image, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            })
        }
    }

    class func retriveLocationDetails(location: CLLocation, completionHandler: @escaping (_ address: Address?) -> Void) {
        let geoCoder = CLGeocoder()

        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if let count = placemarks?.count {
                if count > 0 {
                    let placeMark = placemarks?[0]

                    let addressObj = Address()
                    addressObj.city = placeMark?.locality
                    addressObj.country = placeMark?.country
                    addressObj.postCode = placeMark?.postalCode
                    addressObj.addressStreet = placeMark?.thoroughfare
                    addressObj.addressNumber = placeMark?.subThoroughfare

                    completionHandler(addressObj)
                }
            }

            completionHandler(nil)
        })
    }


    class func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        return emailTest.evaluate(with: email)
    }

    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }

        return nil
    }

    class func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))

        var topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController

        while topController.presentedViewController != nil {
            topController = topController.presentedViewController!
        }

        topController.present(alertController, animated: true, completion: nil)
    }
}

extension String  {
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }

    func sha1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
