//
//  ParkedViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 26/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import MapKit

class ParkedViewController: BaseViewController {
    @IBOutlet private weak var parkImageView: UIImageView!
    @IBOutlet private weak var takeMeHereAddressLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var backButton: UIButton!

    var bikeParkedItem: BikeParkedItem?

    fileprivate var unParkBikeRequest = UnParkBikeRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let address = bikeParkedItem?.address {
            takeMeHereAddressLabel.text = address
        }

        if let photo = bikeParkedItem?.photo {
            parkImageView.image = photo
        } else {
            if let location = bikeParkedItem?.location {
                zoomToCurrentLocation(location: location, maxZoomIn: false, mapView: mapView, animated: true)
                mapView.isHidden = false
                let pin = MKPointAnnotation()
                pin.coordinate = location.coordinate
                self.mapView.addAnnotation(pin)
                backButton.setImage(UIImage(named: "arrow_left_black"), for: .normal)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(removeParkedBikeNotification), name: NSNotification.Name(rawValue: Constants.Notifications.ReportMissingCompleteNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Bike Parked Page")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notifications.ReportMissingCompleteNotification), object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @objc func removeParkedBikeNotification(notification: NSNotification) {
        unparkBike()
        _ = self.navigationController?.popViewController(animated: true)
    }

    fileprivate func unparkBike() {
        if let userId = UserManager.sharedInstance.user?.userId, let parkId = bikeParkedItem?.parkId {
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

            unParkBikeRequest.execute(userId: userId, parkId: parkId, {[weak self] (success, error) in
                LoadingOverlay.shared.hideOverlayView()
                if success {
                    self?.removeParkedBike()
                    _ = self?.navigationController?.popViewController(animated: true)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Unpark bike failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let viewController = nav.viewControllers[0] as? ReportViewController {
            viewController.bikeParkedItem = bikeParkedItem
        }
    }

    // MARK: - IBActions
    @IBAction func unparkAction(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: NSLocalizedString("Please confirm you want to unpark", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Unpark", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.unparkBike()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func takeMeHere(_ sender: UITapGestureRecognizer) {
        if let location = bikeParkedItem?.location {
            openDirectionsToLocation(location: location, name: takeMeHereAddressLabel.text!, walkingDirections: true)
        }
    }
}

extension ParkedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "ParkedPin")
            view.image = UIImage(named: "shop_pin")
            view.isEnabled = true
            let offset = (view.image?.size.height)!/2.0
            view.centerOffset = CGPoint(x: 0, y: -offset)
            view.canShowCallout = false
            return view
        }

        return nil
    }
}
