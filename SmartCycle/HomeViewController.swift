//
//  HomeViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 22/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import CoreLocation
import SideMenu

class HomeViewController: BaseViewController {
    @IBOutlet private weak var bikeParksCountLabel: UILabel!
    @IBOutlet private weak var bikeShopsCountLabel: UILabel!
    @IBOutlet private weak var bikesArroundYouLabel: UILabel!
    @IBOutlet private weak var radiusLabel: UILabel!
    @IBOutlet private weak var unParkView: UIView!
    @IBOutlet private weak var parksActivityView: UIActivityIndicatorView!
    @IBOutlet private weak var shopsActivityView: UIActivityIndicatorView!
    @IBOutlet private weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var footerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cityLabel: UILabel!

    fileprivate var locationManager = CLLocationManager()
    fileprivate var parkNearMeRequest = ParkNearMeRequest()
    fileprivate var shopsNearMeRequest = ShopsNearMeRequest()
    fileprivate var unParkBikeRequest = UnParkBikeRequest()
    fileprivate var parkNearMeArray: [ParkItem] = []
    fileprivate var shopsNearMeArray: [StoreItem] = []
    fileprivate var currentLocation: CLLocation?
    fileprivate var bikeParkedItem: BikeParkedItem?
    fileprivate weak var mapViewController: MapViewController?
    fileprivate var isMapOpen = false
    fileprivate var address = Address()
    fileprivate var forceReload = false

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCountIfNecessary),name: .UIApplicationDidBecomeActive,object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Home Page")
        headerViewHeightConstraint.constant = (self.view.frame.height / 2) + 26
        self.view.layoutIfNeeded()

        checkForParkedBikes()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isMapOpen {
            return .default
        }

        return super.preferredStatusBarStyle
    }

    @objc fileprivate func refreshCountIfNecessary(notification: NSNotification?) {
        locationManager.startUpdatingLocation()
    }

    fileprivate func updateAddress(location: CLLocation) {
        Utils.retriveLocationDetails(location: location) {[weak self] (address) in
            if let address = address {
                self?.address = address
                if let city = address.city, let country = address.country {
                    self?.cityLabel.text = "\(city) (\(country))"
                } else {
                    self?.cityLabel.text = NSLocalizedString("Unknown location", comment: "")
                }

                self?.startAllDataRequests()
            }
        }
    }

    fileprivate func checkForParkedBikes() {
        bikeParkedItem = nil

        if let data = UserDefaults.standard.object(forKey: Constants.UserDefaults.BikeParkedData) as? Data {
            let unarc = NSKeyedUnarchiver(forReadingWith: data)
            unarc.setClass(BikeParkedItem.self, forClassName: "BikeParkedItem")
            if let bikeParkedItem = unarc.decodeObject(forKey: "root") as? BikeParkedItem {
                self.bikeParkedItem = bikeParkedItem
            }
        }

        if let bikeParkedItem = bikeParkedItem {
            bikeParksCountLabel.isHidden = false
            bikeParksCountLabel.text = "P"
            parksActivityView.stopAnimating()
            bikesArroundYouLabel.text = NSLocalizedString("Your bike is parked in", comment: "")
            radiusLabel.text = bikeParkedItem.address
        } else {
            bikesArroundYouLabel.text = NSLocalizedString("Bike parks around you", comment: "")
            radiusLabel.text = NSLocalizedString("1 mile radius", comment: "")
            bikeParksCountLabel.text = String(parkNearMeArray.count)
        }

        self.unParkView.alpha = self.bikeParkedItem == nil ? 0 : 1

        locationManager.startUpdatingLocation()
    }

    fileprivate func isBikeParked() -> Bool {
        if let _ = bikeParkedItem {
            return true
        }

        return false
    }

    fileprivate func searchForParksNearMe() {
        if let currentLocation = currentLocation, let userId = UserManager.sharedInstance.user?.userId {
            parkNearMeRequest.execute(location: currentLocation, radius: Float(Constants.Variables.DefaultRadius), userId: userId, {[weak self] (results, error) in
                self?.parksActivityView.stopAnimating()
                if let error = error {
                    let alert = UIAlertController(title: NSLocalizedString("Park Near me service failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if let results = results {
                    if self?.isBikeParked() == false {
                        self?.bikeParksCountLabel.isHidden = false
                        self?.bikeParksCountLabel.text = String(results.count)
                    }
                    self?.parkNearMeArray = results
                }
            })
        }
    }

    fileprivate func searchForShopsNearMe() {
        if let currentLocation = currentLocation, let userId = UserManager.sharedInstance.user?.userId {
            shopsNearMeRequest.execute(location: currentLocation, radius: Float(Constants.Variables.DefaultRadius), userId: userId, {[weak self] (results, error) in
                self?.shopsActivityView.stopAnimating()
                if let error = error {
                    let alert = UIAlertController(title: NSLocalizedString("Shops Near me service failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if let results = results {
                    self?.shopsNearMeArray = results
                    self?.bikeShopsCountLabel.text = String(results.count)
                }
            })
        }
    }

    fileprivate func animateMapIn() {
        headerViewTopConstraint.constant = -headerViewHeightConstraint.constant
        footerViewBottomConstraint.constant = -headerViewHeightConstraint.constant
        isMapOpen = true
        setNeedsStatusBarAppearanceUpdate()

        UIView.animate(withDuration: 0.5) { 
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func animateMapOut() {
        headerViewTopConstraint.constant = 0
        footerViewBottomConstraint.constant = 0
        isMapOpen = false
        setNeedsStatusBarAppearanceUpdate()

        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.checkForParkedBikes()
        }
    }

    fileprivate func startAllDataRequests() {
        searchForParksNearMe()
        searchForShopsNearMe()
    }

    fileprivate func unparkBike() {
        if let userId = UserManager.sharedInstance.user?.userId, let parkId = bikeParkedItem?.parkId {
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

            unParkBikeRequest.execute(userId: userId, parkId: parkId, {[weak self] (success, error) in
                LoadingOverlay.shared.hideOverlayView()
                if success {
                    self?.removeParkedBike()
                    self?.checkForParkedBikes()
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Unpark bike failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MapViewController {
            mapViewController = viewController
            mapViewController?.delegate = self
        } else if let viewController = segue.destination as? ParkedViewController, let bikeParkedItem = bikeParkedItem {
            viewController.bikeParkedItem = bikeParkedItem
        }
    }

    // MARK: - IBActions
    @IBAction func parkButtonTapped(_ sender: UITapGestureRecognizer) {
        if isBikeParked() {
            self.performSegue(withIdentifier: Constants.Storyboard.Segue.ParkedBikeSegue, sender: nil)
        } else {
            mapViewController?.reloadMapData(mapType: .Parks, items: parkNearMeArray, address: address)
            animateMapIn()
        }
    }

    @IBAction func shopsButtonTapped(_ sender: UITapGestureRecognizer) {
        mapViewController?.reloadMapData(mapType: .Shops, items: shopsNearMeArray)
        animateMapIn()
    }

    @IBAction func unparkAction(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: NSLocalizedString("Please confirm you want to unpark", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Unpark", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.unparkBike()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            if let currentLocation = currentLocation {
                let distanceInMeters = currentLocation.distance(from: location)
                if distanceInMeters > 500.0 || forceReload {
                    loadData(location: location)
                }
            } else {
                loadData(location: location)
            }
        }
    }

    fileprivate func loadData(location: CLLocation) {
        forceReload = false
        currentLocation = location
        mapViewController?.prepareMap(location: location)
        updateAddress(location: location)
    }
}

extension HomeViewController: MapViewControllerDelegate {
    func hideMap() {
        animateMapOut()
        checkForParkedBikes()
    }

    func bikeAddedFlag() {
        forceReload = true
    }
}
