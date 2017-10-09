//
//  EditProfileViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 19/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import MobileCoreServices
import Cloudinary

class EditProfileViewController: BaseViewController {
    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    @IBOutlet fileprivate weak var firstNameTextField: UITextField!
    @IBOutlet fileprivate weak var lastNameTextField: UITextField!
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var addressTextField: UITextField!
    @IBOutlet fileprivate weak var cityTextField: UITextField!
    @IBOutlet fileprivate weak var postcodeTextField: UITextField!
    @IBOutlet fileprivate weak var countryTextField: UITextField!
    @IBOutlet fileprivate weak var phoneTextField: UITextField!
    @IBOutlet fileprivate weak var genderTextField: UITextField!
    @IBOutlet fileprivate weak var dateOfBirthTextField: UITextField!
    @IBOutlet fileprivate weak var scrollview: UIScrollView!
    @IBOutlet fileprivate weak var pickerViewContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var datePicker: UIDatePicker!
    @IBOutlet fileprivate weak var twitterTextField: UITextField!

    fileprivate var activeField: UITextField?
    fileprivate var updateUserRequest = UpdateUserRequest()
    fileprivate let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: Constants.Keys.CloudinaryUsername, apiKey: Constants.Keys.CloudinaryAPIKey))

    override func viewDidLoad() {
        super.viewDidLoad()

        Branding.makeImageRounded(image: profileImageView)

        self.registerForKeyboardNotifications()
        populateUserData()
        datePicker.maximumDate = Date()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Edit Profile Page")
    }

    deinit {
        self.deregisterFromKeyboardNotifications()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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

    fileprivate func populateUserData() {
        if let user = UserManager.sharedInstance.user {
            if let profileImage = user.profileImage {
                profileImageView.image = profileImage
            }

            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
            emailTextField.text = user.email

            if let address = user.address {
                addressTextField.text = address
            }

            if let city = user.city {
                cityTextField.text = city
            }

            if let postCode = user.postCode {
                postcodeTextField.text = postCode
            }

            if let country = user.country {
                countryTextField.text = country
            }

            if let phone = user.phoneNumber {
                phoneTextField.text = phone
            }

            if let gender = user.gender {
                genderTextField.text = gender
            }

            if let twitterHandler = user.twitter {
                twitterTextField.text = twitterHandler
            }

            if let dateOfBirth = user.dateOfBirth {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Constants.DateFormat.SimpleDateFormat
                dateOfBirthTextField.text = dateFormatter.string(from: dateOfBirth)
                datePicker.setDate(dateOfBirth, animated: false)
            }
        }
    }

    fileprivate func showGenderMenu() {
        let alert = UIAlertController(title: NSLocalizedString("Please select", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Male", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.genderTextField.text = NSLocalizedString("Male", comment: "")
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Female", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.genderTextField.text = NSLocalizedString("Female", comment: "")
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Other", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.genderTextField.text = NSLocalizedString("Other", comment: "")
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func showCalendar() {
        pickerViewContainerBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func hideCalendar() {
        pickerViewContainerBottomConstraint.constant = -260

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func validateForm() -> Bool {
        var errorMessage: String?

        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errorMessage = NSLocalizedString("First name is a mandatory field.", comment: "")
        }

        if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errorMessage = NSLocalizedString("Last name is a mandatory field.", comment: "")
        }

        if let errorMessage = errorMessage {
            let alert = UIAlertController(title: NSLocalizedString("Error editing profile", comment: ""), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return false
        }
        
        return true
    }

    // MARK: - IBActions
    @IBAction func save(_ sender: UIButton?) {
        if !validateForm() {
            return
        }

        if let user = UserManager.sharedInstance.user {
            let updatedUser = user
            if let _ = user.profileCloudinaryPhotoId {
                updatedUser.profileImage = profileImageView.image
            }

            if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.firstName = firstNameTextField.text!
            }

            if lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.lastName = lastNameTextField.text!
            }

            if addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.address = addressTextField.text
            }

            if cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.city = cityTextField.text
            }

            if postcodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.postCode = postcodeTextField.text
            }

            if countryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.country = countryTextField.text
            }

            if phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.phoneNumber = phoneTextField.text
            }

            if genderTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.gender = genderTextField.text
            }

            if twitterTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                updatedUser.twitter = twitterTextField.text
            }

            UserManager.sharedInstance.loadUser(user: updatedUser)

            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
            updateUserRequest.execute(user: updatedUser) { (success, error) in
                LoadingOverlay.shared.hideOverlayView()
                if success {
                    let alert = UIAlertController(title: NSLocalizedString("Profile updated", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                        _ = self.navigationController?.popViewController(animated: true)
                    }))

                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Update profile failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func hidePickerButtonTapped(_ sender: UIBarButtonItem?) {
        hideCalendar()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DateFormat.SimpleDateFormat
        dateOfBirthTextField.text = dateFormatter.string(from: datePicker.date)
        UserManager.sharedInstance.user?.dateOfBirth = datePicker.date
    }

    @IBAction func profileImageTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: NSLocalizedString("Do you want to use existing photo or take a new one?", comment: ""), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Take new photo", comment: ""), style: .default , handler:{ (UIAlertAction)in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.openCamera(viewController: self, imagePicker: imagePicker, rearCamera: false)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Open camera roll", comment: ""), style: .default , handler:{ (UIAlertAction)in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.openCameraRoll(viewController: self, imagePicker: imagePicker)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }
}

extension EditProfileViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        self.dismiss(animated: true, completion: nil)

        if mediaType.isEqual(to: kUTTypeImage as String) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let userId = UserManager.sharedInstance.user?.userId {

                Utils.uploadToCloudinary(cloudinary: cloudinary, image: image, folder: "UserProfile", publicId: userId, completionHandler: {[weak self] (publicId, version) in
                    if let publicId = publicId {
                        UserManager.sharedInstance.user?.profileCloudinaryPhotoId = publicId
                        UserManager.sharedInstance.user?.profileCloudinaryVersion = version
                        Utils.loadCloudinaryImage(cloudinary: (self?.cloudinary)!, publicId: publicId, version: version, imageView: (self?.profileImageView)!)
                    }
                })
            }
        } 
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == genderTextField {
            self.view.endEditing(true)
            showGenderMenu()
            return false
        } else if textField == dateOfBirthTextField {
            self.view.endEditing(true)
            showCalendar()
            return false
        }

        return true
    }
}
