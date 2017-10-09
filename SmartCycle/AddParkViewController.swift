//
//  AddParkViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 19/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import MapKit
import MobileCoreServices
import Cloudinary

struct ParkingType {
    var title: String
    let image: String
}

protocol AddParkViewControllerDelegate: class {
    func addPark(item: ParkItem)
}

class AddParkViewController: BaseViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var parkPhoto: UIImageView!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    @IBOutlet fileprivate weak var parkingTypeLabel: UILabel!
    @IBOutlet fileprivate weak var parkingTypeImage: UIImageView!
    @IBOutlet fileprivate weak var spacesCountLabel: UILabel!

    var currentLocation: CLLocation?
    var address: Address?
    weak var delegate: AddParkViewControllerDelegate?

    fileprivate var parkItem: ParkItem?
    fileprivate var parkImage: UIImage?
    fileprivate let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: Constants.Keys.CloudinaryUsername, apiKey: Constants.Keys.CloudinaryAPIKey))
    fileprivate let parkingTypeArray = [ParkingType(title:"Sheffield stand/ U-rack", image:"U-rack"), ParkingType(title:"Wall bars", image:"Wall bars bike"), ParkingType(title:"Cycle lockers", image:"Cycle lockers"), ParkingType(title:"Parking rack", image:"Parking Rack"), ParkingType(title:"Finsbury Park style", image:"Finsbury Park style"), ParkingType(title:"Bike hangars", image:"Bike hangars"), ParkingType(title:"Wall hoop", image:"Wall hoop"), ParkingType(title:"Other", image:"Other")]

    fileprivate var parkTypeSelectedIndex = 0
    fileprivate var spacesCount = 0
    fileprivate var addParkRequest = AddParkRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        if let address = address {
            addressLabel.text = address.fullAddress()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Add Park Page")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    fileprivate func setupMap() {
        if let currentLocation = currentLocation {
            zoomToCurrentLocation(location: currentLocation, maxZoomIn: true, mapView: mapView, animated: false)
            self.parkItem = ParkItem(location: currentLocation)
        }
    }

    // MARK: - IBActions
    @IBAction func editParkPhoto(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.openCamera(viewController: self, imagePicker: imagePicker, rearCamera: true)
    }

    @IBAction func submitPark(_ sender: UITapGestureRecognizer) {
        if let parkItem = parkItem, let address = address {
            parkItem.address = address
            parkItem.location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            parkItem.type = parkingTypeArray[parkTypeSelectedIndex].title
            parkItem.capacity = "\(spacesCount)"

            if let userId = UserManager.sharedInstance.user?.userId {
                LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

                addParkRequest.execute(parkItem: parkItem, userId: userId) {[weak self] (parkId, error) in
                    LoadingOverlay.shared.hideOverlayView()
                    if let error = error {
                        let alert = UIAlertController(title: NSLocalizedString("Add park failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("Park successfully added.", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                            parkItem.parkId = parkId
                            self?.delegate?.addPark(item: parkItem)
                            _ = self?.navigationController?.popViewController(animated: true)
                        }))

                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @IBAction func stepperLeft(_ sender: UIButton?) {
        parkTypeSelectedIndex = parkTypeSelectedIndex - 1
        if parkTypeSelectedIndex < 0 {
            parkTypeSelectedIndex = parkingTypeArray.count - 1
        }

        parkingTypeLabel.text = parkingTypeArray[parkTypeSelectedIndex].title
        parkingTypeImage.image = UIImage(named: parkingTypeArray[parkTypeSelectedIndex].image)
    }

    @IBAction func stepperRight(_ sender: UIButton?) {
        parkTypeSelectedIndex = parkTypeSelectedIndex + 1
        if parkTypeSelectedIndex >= parkingTypeArray.count {
            parkTypeSelectedIndex = 0
        }

        parkingTypeLabel.text = parkingTypeArray[parkTypeSelectedIndex].title
        parkingTypeImage.image = UIImage(named: parkingTypeArray[parkTypeSelectedIndex].image)
    }

    @IBAction func stepperUp(_ sender: UIButton) {
        spacesCount = spacesCount + 1
        spacesCountLabel.text = "\(spacesCount)"
    }

    @IBAction func stepperDown(_ sender: UIButton) {
        spacesCount = max(spacesCount - 1, 0)
        spacesCountLabel.text = "\(spacesCount)"
    }

    @IBAction func parkTypeSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            stepperRight(nil)
        } else if sender.direction == .right {
            stepperLeft(nil)
        }
    }
}

extension AddParkViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let _ = parkItem {
            Utils.retriveLocationDetails(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)) {[weak self] (address) in
                if let address = address {
                    self?.address = address
                    self?.addressLabel.text = address.fullAddress()
                }
            }
        }
    }
}

extension AddParkViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        self.dismiss(animated: true, completion: nil)

        if mediaType.isEqual(to: kUTTypeImage as String) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                Utils.uploadToCloudinary(cloudinary: cloudinary, image: image, folder: "Parks", publicId: parkItem?.parkCloudinaryPhotoId != nil ? parkItem?.parkCloudinaryPhotoId : nil, completionHandler: {[weak self] (publicId, version) in
                    if let publicId = publicId {
                        self?.parkItem?.parkCloudinaryPhotoId = publicId
                        Utils.loadCloudinaryImage(cloudinary: (self?.cloudinary)!, publicId: publicId, imageView: (self?.parkPhoto)!)
                    }
                })
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
