//
//  ParkViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 23/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import MobileCoreServices
import Cloudinary

protocol ParkViewControllerDelegate: class {
    func hideParkDetailsPanel()
    func maximizeParkPanel(topConstraint: CGFloat)
    func hideMap()
}

class ParkViewController: BaseViewController {
    @IBOutlet private weak var parkImageView: UIImageView!
    @IBOutlet private weak var takeMeHereAddressLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var capacityLabel: UILabel!
    @IBOutlet private weak var parkTypeLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!

    weak var delegate: ParkViewControllerDelegate?

    fileprivate var parkItem: ParkItem?
    fileprivate var parkingPhoto: UIImage?
    fileprivate var ismaximized = false
    fileprivate var panelTopConstraint: CGFloat = 250
    fileprivate var panelOldContentOffset = CGPoint.zero
    fileprivate var panelTopConstraintRange: Range<CGFloat> = (CGFloat(80)..<CGFloat(250))
    fileprivate var panelMinimumRange: CGFloat = 80.0
    fileprivate let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: Constants.Keys.CloudinaryUsername, apiKey: Constants.Keys.CloudinaryAPIKey))
    fileprivate var parkBikeRequest = ParkBikeRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Park Panel Page")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let panelContentSizeHeight = self.scrollView.contentSize.height
        let parentHeight = self.parent?.view.frame.height ?? 0

        if (panelContentSizeHeight + panelMinimumRange) < parentHeight {
            panelMinimumRange = parentHeight - panelContentSizeHeight + 5.0
            panelTopConstraintRange = (CGFloat(panelMinimumRange)..<CGFloat(250))
        }
    }

    func loadDetails(item: ParkItem) {
        self.parkItem = item
        panelTopConstraint = 250
        if let capacity = item.capacity, let parkType = item.type, let location = item.location {

            Utils.retriveLocationDetails(location: location) {[weak self] (address) in
                if let address = address {
                    self?.parkItem?.address = address
                    self?.takeMeHereAddressLabel.text = address.fullAddress()
                    self?.addressLabel.text = address.fullAddress()
                }
            }

            capacityLabel.text = capacity
            parkTypeLabel.text = parkType
        }

        if let publicId = item.parkCloudinaryPhotoId {
            Utils.loadCloudinaryImage(cloudinary: cloudinary, publicId: publicId, imageView: parkImageView)
        }

        parkImageView.image = UIImage(named: "parkPlaceholder")
    }

    fileprivate func saveParking() {
        if let location = self.parkItem?.location, let parkId = self.parkItem?.parkId {
            let bikeParkedItem = BikeParkedItem(address: self.takeMeHereAddressLabel.text!, parkId: parkId, photo: parkingPhoto, location: location)

            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: bikeParkedItem), forKey: Constants.UserDefaults.BikeParkedData)
            UserDefaults.standard.synchronize()

            let alert = UIAlertController(title: NSLocalizedString("Parking saved", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                self.delegate?.hideMap()
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func addParking() {
        if let userId = UserManager.sharedInstance.user?.userId, let parkItem = parkItem {
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

            parkBikeRequest.execute(userId: userId, parkItem: parkItem) {[weak self] (parkId, error) in
                LoadingOverlay.shared.hideOverlayView()
                if let error = error {
                    let alert = UIAlertController(title: NSLocalizedString("Parking failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.parkItem?.parkId = parkId
                    self?.saveParking()
                }
            }
        }
    }

    // MARK: - IBActions
    @IBAction func parkHere(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: NSLocalizedString("Please confirm you want to park here", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Park here", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.addParking()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Park here and take a photo", comment: ""), style: .default , handler:{ (UIAlertAction)in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.openCamera(viewController: self, imagePicker: imagePicker, rearCamera: true)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func takeMeHere(_ sender: UITapGestureRecognizer) {
        if let location = parkItem?.location {
            openDirectionsToLocation(location: location, name: addressLabel.text!, walkingDirections: false)
        }
    }
}

extension ParkViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -50 {
            ismaximized = false
            self.delegate?.hideParkDetailsPanel()
            panelTopConstraint = 250
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta =  scrollView.contentOffset.y - panelOldContentOffset.y

        if delta > 0 && panelTopConstraint > panelTopConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
            panelTopConstraint -= delta
            panelTopConstraint = CGFloat.maximum(panelMinimumRange, panelTopConstraint)
            scrollView.contentOffset.y -= delta
            self.delegate?.maximizeParkPanel(topConstraint: panelTopConstraint)
        }
        
        panelOldContentOffset = scrollView.contentOffset
    }
}

extension ParkViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        self.dismiss(animated: true, completion: nil)

        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            parkingPhoto = image

            addParking()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.hideParkDetailsPanel()
        self.dismiss(animated: true, completion: nil)
    }
}

