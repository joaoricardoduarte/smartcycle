//
//  BaseViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 22/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import MapKit
import MobileCoreServices

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var prefersStatusBarHidden : Bool {
        return presentingViewController?.prefersStatusBarHidden ?? false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func zoomToCurrentLocation(location: CLLocation, maxZoomIn: Bool, mapView: MKMapView, animated: Bool) {
        let zoomValue = maxZoomIn ? 0.00090 : 0.015
        let span = MKCoordinateSpan.init(latitudeDelta: zoomValue, longitudeDelta: zoomValue)
        let region = MKCoordinateRegion.init(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: animated)
    }

    func removeParkedBike() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.BikeParkedData)
        UserDefaults.standard.synchronize()

        let alert = UIAlertController(title: NSLocalizedString("Unparking complete", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func openDirectionsToLocation(location: CLLocation, name: String, walkingDirections: Bool) {
        let alert = UIAlertController(title: NSLocalizedString("This will open Apple Maps with direction to this location", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default , handler:{ (UIAlertAction)in
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate, addressDictionary:nil))
            mapItem.name = name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : walkingDirections ? MKLaunchOptionsDirectionsModeWalking : MKLaunchOptionsDirectionsModeDriving])
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }

    func openCamera(viewController: BaseViewController, imagePicker: UIImagePickerController, rearCamera: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.cameraDevice = rearCamera ? .rear : .front
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func openCameraRoll(viewController: BaseViewController, imagePicker: UIImagePickerController) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func backButton(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension BaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: NSLocalizedString("Save Failed", comment: ""), message: NSLocalizedString("Failed to save image", comment: ""), preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil)

            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func setScreenName(name: String) {
        self.title = name
        self.sendScreenView()
    }

    func sendScreenView() {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.set(kGAIScreenName, value: self.title)
        tracker!.send(GAIDictionaryBuilder.createScreenView()?.build() as [NSObject : AnyObject]!)
    }

    func trackEvent(category: String, action: String, label: String, value: NSNumber?) {
        let tracker = GAI.sharedInstance().defaultTracker
        let trackDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        tracker?.send(trackDictionary?.build() as [NSObject : AnyObject]!)
    }
}

