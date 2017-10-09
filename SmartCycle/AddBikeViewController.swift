//
//  AddBikeViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 27/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import MobileCoreServices
import Cloudinary

class AddBikeViewController: BaseViewController {
    @IBOutlet fileprivate weak var bikeImageView: UIImageView!
    @IBOutlet fileprivate weak var bikeTypeLabel: UILabel!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var modelTextField: UITextField!
    @IBOutlet fileprivate weak var primaryColorTextField: UITextField!
    @IBOutlet fileprivate weak var otherColorTextField: UITextField!
    @IBOutlet fileprivate weak var frameNumberTextField: UITextField!
    @IBOutlet fileprivate weak var scrollview: UIScrollView!

    fileprivate var bikeTypeSelectedIndex = 0
    fileprivate let bikeTypeArray = ["BMX", "City bike", "Comfort", "Cruiser", "Cyclocross", "Flat-Foot", "Folding", "Hybrid", "Mountain", "Performance", "Recumbent", "Road", "Tandem Trike", "Touring", "Track/Fixed-Gear", "Trial Flat-bar road", "Triathlon/Time"]

    fileprivate var bikePhoto: UIImage?
    fileprivate var bikeCloudinaryPhotoId: String?
    fileprivate var addBikeRequest = AddBikeRequest()
    fileprivate var activeField: UITextField?
    fileprivate let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: Constants.Keys.CloudinaryUsername, apiKey: Constants.Keys.CloudinaryAPIKey))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerForKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Add Bike Page")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    deinit {
        self.deregisterFromKeyboardNotifications()
    }

    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        self.scrollview.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)

        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height

        if activeField != nil {
            if (!aRect.contains(activeField!.frame.origin)) {
                self.scrollview.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollview.isScrollEnabled = false
    }

    // MARK: - IBActions
    @IBAction func add(_ sender: UIButton?) {
        activeField?.resignFirstResponder()

        if primaryColorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || (nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))! == "" {
            let alert = UIAlertController(title: NSLocalizedString("Add bike failed", comment: ""), message: NSLocalizedString("Please supply at least Brand and Color", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        }

        let bikeItem = BikeItem()
        bikeItem.brand = nameTextField.text
        bikeItem.type = bikeTypeLabel.text
        bikeItem.model = modelTextField.text
        bikeItem.primaryColor = primaryColorTextField.text
        bikeItem.otherColor = otherColorTextField.text
        bikeItem.frameNumber = frameNumberTextField.text
        bikeItem.photoCloudinaryId = bikeCloudinaryPhotoId
        bikeItem.photo = bikePhoto

        UserManager.sharedInstance.addBike(item: bikeItem)

        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

        if let userId = UserManager.sharedInstance.user?.userId {
            addBikeRequest.execute(bikeItem: bikeItem, userId: userId) { (bikeId, error) in
                LoadingOverlay.shared.hideOverlayView()
                if let error = error {
                    let alert = UIAlertController(title: NSLocalizedString("Add bike failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Bike saved", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                        _ = self.navigationController?.popViewController(animated: true)
                    }))

                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func addPhoto(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: NSLocalizedString("Do you want to use existing photo or take a new one?", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Take new photo", comment: ""), style: .default , handler:{ (UIAlertAction)in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.openCamera(viewController: self, imagePicker: imagePicker, rearCamera: true)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Open camera roll", comment: ""), style: .default , handler:{ (UIAlertAction)in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.openCameraRoll(viewController: self, imagePicker: imagePicker)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func stepperLeft(_ sender: UIButton?) {
        bikeTypeSelectedIndex = bikeTypeSelectedIndex - 1
        if bikeTypeSelectedIndex < 0 {
            bikeTypeSelectedIndex = bikeTypeArray.count - 1
        }

        bikeTypeLabel.text = bikeTypeArray[bikeTypeSelectedIndex]
    }

    @IBAction func stepperRight(_ sender: UIButton?) {
        bikeTypeSelectedIndex = bikeTypeSelectedIndex + 1
        if bikeTypeSelectedIndex >= bikeTypeArray.count {
            bikeTypeSelectedIndex = 0
        }

        bikeTypeLabel.text = bikeTypeArray[bikeTypeSelectedIndex]
    }

    @IBAction func bikeTypeSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            stepperRight(nil)
        } else if sender.direction == .right {
            stepperLeft(nil)
        }
    }
}

extension AddBikeViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        self.dismiss(animated: true, completion: nil)

        if mediaType.isEqual(to: kUTTypeImage as String) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

                Utils.uploadToCloudinary(cloudinary: cloudinary, image: image, folder: "Bikes", publicId: bikeCloudinaryPhotoId, completionHandler: {[weak self] (publicId, version) in
                    if let publicId = publicId {
                        self?.bikeCloudinaryPhotoId = publicId
                        Utils.loadCloudinaryImage(cloudinary: (self?.cloudinary)!, publicId: publicId, imageView: (self?.bikeImageView)!)
                    }
                })
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddBikeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add(nil)
        textField.resignFirstResponder()

        return true
    }
}
