//
//  MapViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 14/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import MapKit

enum MapType {
    case Parks
    case Shops
    case None
}

protocol MapViewControllerDelegate: class {
    func hideMap()
    func bikeAddedFlag()
}

class MapViewController: BaseViewController {
    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var detailsViewContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var detailsViewContainerHeightnstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var addParkView: UIView!
    @IBOutlet fileprivate weak var containerView: UIView!

    weak var delegate: MapViewControllerDelegate?

    fileprivate var mapType = MapType.None
    fileprivate var selectedPin: MKAnnotation?
    fileprivate var parkViewController: ParkViewController?
    fileprivate var shopViewController: ShopViewController?
    fileprivate var isParked = false
    fileprivate var currentLocation: CLLocation?
    fileprivate var items: [Any] = []
    fileprivate var address: Address?
    fileprivate var locationManager = CLLocationManager()
    fileprivate var parkNearMeRequest = ParkNearMeRequest()
    fileprivate var shopsNearMeRequest = ShopsNearMeRequest()
    fileprivate var reloadWithNewData = false
    fileprivate var useMaxRadius = false

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshMapIfNecessary),name: .UIApplicationDidBecomeActive,object: nil)
        locationManager.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Map Page")

        detailsViewContainerTopConstraint.constant = self.view.frame.size.height
        let topConstant: CGFloat = mapType == .Parks ? 250 : 287
        detailsViewContainerHeightnstraint.constant = self.view.frame.size.height - topConstant
        self.view.layoutIfNeeded()
    }

    @objc func refreshMapIfNecessary(notification: NSNotification) {
        locationManager.startUpdatingLocation()
    }

    func prepareMap(location: CLLocation) {
        currentLocation = location
        zoomToCurrentLocation(location: location, maxZoomIn: false, mapView: mapView, animated: true)
    }

    func reloadMapData(mapType: MapType, items: [Any], address: Address = Address()) {
        self.items = items
        self.address = address

        if self.mapType == mapType && !reloadWithNewData {
            return
        }

        self.mapType = mapType
        if !reloadWithNewData {
            handleEmbededViewControllersForInfoPanel()
        }
        mapView.removeAnnotations(mapView.annotations)
        addPins()
        reloadWithNewData = false
    }

    fileprivate func updateAddress(location: CLLocation) {
        Utils.retriveLocationDetails(location: location) {[weak self] (address) in
            if let address = address {
                self?.address = address
                self?.searchForParksNearMe()
            }
        }
    }

    func handleEmbededViewControllersForInfoPanel() {
        let storyboard = UIStoryboard(name: Constants.Storyboard.MainStoryboard, bundle: nil)
        addParkView.isHidden = mapType == .Parks ? false : true

        switch mapType {
        case .Shops:
            if let parkViewController = parkViewController {
                removeEmbededViewController(viewController: parkViewController)
            }

            if let shopViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.ViewController.ShopViewController) as? ShopViewController {
                addEmbededViewController(viewController: shopViewController)
                shopViewController.delegate = self
                self.shopViewController = shopViewController
            }

            break
        case .Parks:
            if let shopViewController = shopViewController {
                removeEmbededViewController(viewController: shopViewController)
            }

            if let parkViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.ViewController.ParkViewController) as? ParkViewController {
                addEmbededViewController(viewController: parkViewController)
                parkViewController.delegate = self
                self.parkViewController = parkViewController
            }

            break
        default:
            break
        }
    }

    fileprivate func addEmbededViewController(viewController: BaseViewController) {
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
    }

    fileprivate func removeEmbededViewController(viewController: BaseViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    fileprivate func addPins() {
        for item in items {
            var pin: MKAnnotation?

            if let item = item as? ParkItem {
                pin = ParkLocationAnnotation(item: item)
            } else if let item = item as? StoreItem {
                pin = ShopLocationAnnotation(item: item)
            }

            if let pin = pin {
                self.mapView.addAnnotation(pin)
            }
        }
    }

    fileprivate func hideDetails() {
        mapView.deselectAnnotation(selectedPin, animated: true)
        detailsViewContainerTopConstraint.constant = self.view.frame.size.height
        addParkView.isHidden = mapType == .Parks ? false : true

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func maximizeInfo(topConstraint: CGFloat) {
        detailsViewContainerTopConstraint.constant = topConstraint
        detailsViewContainerHeightnstraint.constant = self.view.bounds.height - topConstraint
        addParkView.isHidden = true

        self.view.layoutIfNeeded()
    }

    fileprivate func searchForParksNearMe() {
        if let currentLocation = currentLocation, let userId = UserManager.sharedInstance.user?.userId {
            let zoom = useMaxRadius ? Constants.Variables.MaxRadius : Constants.Variables.DefaultRadius
            parkNearMeRequest.execute(location: currentLocation, radius: Float(zoom), userId: userId, {[weak self] (results, error) in
                if let error = error {
                    let alert = UIAlertController(title: NSLocalizedString("Park Near me service failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if let results = results, let address = self?.address {
                    self?.reloadMapData(mapType: .Parks, items: results, address: address)
                }
            })
        }
    }

    fileprivate func searchForShopsNearMe() {
        if let currentLocation = currentLocation, let userId = UserManager.sharedInstance.user?.userId {
            let zoom = useMaxRadius ? Constants.Variables.MaxRadius : Constants.Variables.DefaultRadius
            shopsNearMeRequest.execute(location: currentLocation, radius: Float(zoom), userId: userId, {[weak self] (results, error) in
                if let error = error {
                    let alert = UIAlertController(title: NSLocalizedString("Shops Near me service failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if let results = results {
                    self?.reloadMapData(mapType: .Shops, items: results)
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AddParkViewController {
            viewController.currentLocation = currentLocation
            viewController.address = address
            viewController.delegate = self
        }
    }

    // MARK: - IBActions
    @IBAction func hideMap(_ sender: UIButton?) {
        delegate?.hideMap()
        hideDetails()
    }
}

extension MapViewController: ParkViewControllerDelegate {
    func hideParkDetailsPanel() {
        hideDetails()
    }

    func maximizeParkPanel(topConstraint: CGFloat) {
        maximizeInfo(topConstraint: topConstraint)
    }

    func hideMap() {
        hideMap(nil)
    }
}

extension MapViewController: ShopViewControllerDelegate {
    func hideShopDetailsPanel() {
        hideDetails()
    }

    func maximizeShopPanel(topConstraint: CGFloat) {
        maximizeInfo(topConstraint: topConstraint)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkLocationAnnotation {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier){
                return view
            } else {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                let image = UIImage(named: "park_pin")
                view.image = image
                view.isEnabled = true
                let offset = (image?.size.height)!/2.0
                view.centerOffset = CGPoint(x: 0, y: -offset)
                view.canShowCallout = false
                return view
            }
        } else if let annotation = annotation as? ShopLocationAnnotation {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier){
                return view
            } else {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                let image = UIImage(named: "shop_pin")
                view.image = image
                view.isEnabled = true
                let offset = (image?.size.height)!/2.0
                view.centerOffset = CGPoint(x: 0, y: -offset)
                view.canShowCallout = false
                return view
            }
        }

        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pin = view.annotation as? ParkLocationAnnotation, let parkViewController = parkViewController, let parkItem = pin.parkItem {
            selectedPin = pin
            parkViewController.loadDetails(item: parkItem)
        } else if let pin = view.annotation as? ShopLocationAnnotation, let shopViewController = shopViewController, let item = pin.shopItem {
            selectedPin = pin
            shopViewController.loadDetails(item: item)
        }

        let topConstant: CGFloat = mapType == .Parks ? 250 : 287
        detailsViewContainerTopConstraint.constant = topConstant

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(log2(zoomWidth)) - 9

        useMaxRadius = zoomFactor >= 6 ? true : false

        let updatedLocation = CLLocation(latitude: mapView.camera.centerCoordinate.latitude, longitude: mapView.camera.centerCoordinate.longitude)
        if let currentLocation = currentLocation {
            let distance = updatedLocation.distance(from: currentLocation)
            if distance > 1000.0 && !useMaxRadius {
                loadData(location: updatedLocation)
            } else if distance > 10000.0 && useMaxRadius {
                loadData(location: updatedLocation)
            }
        }
    }
}

extension MapViewController: AddParkViewControllerDelegate {
    func addPark(item: ParkItem) {
        let pin = ParkLocationAnnotation(item: item)
        self.mapView.addAnnotation(pin)
        delegate?.bikeAddedFlag()
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            if let currentLocation = currentLocation {
                let distanceInMeters = currentLocation.distance(from: location)
                if distanceInMeters > 500.0 {
                    prepareMap(location: location)
                    loadData(location: location)
                }
            }
        }
    }

    fileprivate func loadData(location: CLLocation) {
        currentLocation = location
        reloadWithNewData = true
        switch mapType {
        case .Parks:
            updateAddress(location: location)
            break

        case .Shops:
            searchForShopsNearMe()
            break

        default:
            break
        }
    }
}
