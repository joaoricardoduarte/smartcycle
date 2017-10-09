//
//  SignUpViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 23/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

class SignUpViewController: BaseViewController {
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!

    fileprivate var signUpRequest = SignUpRequest()
    fileprivate var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerForKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Sign Up Page")
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
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height

        if activeField != nil {
            if (!aRect.contains(activeField!.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    fileprivate func validateForm() -> Bool {
        var errorMessage: String?

        if passwordTextField.text != confirmPasswordTextField.text {
            errorMessage = NSLocalizedString("Password does not match the confirm password.", comment: "")
        }

        if !Utils.isValidEmail(email: emailTextField.text!) {
            errorMessage = NSLocalizedString("Please use a valid email.", comment: "")
        }

        if passwordTextField.text?.characters.count == 0 || emailTextField.text?.characters.count == 0 || confirmPasswordTextField.text?.characters.count == 0 || firstNameTextField.text?.characters.count == 0 || lastNameTextField.text?.characters.count == 0 {
            errorMessage = NSLocalizedString("Please fill all the fields.", comment: "")
        }

        if (passwordTextField.text?.characters.count)! < 6 {
            errorMessage = NSLocalizedString("Password needs a minimum of 6 characters.", comment: "")
        }

        if let errorMessage = errorMessage {
            let alert = UIAlertController(title: NSLocalizedString("Sign Up", comment: ""), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return false
        }

        return true
    }

    fileprivate func performSmartCycleRegistration() {
        signUpRequest.execute(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) {[weak self] (success, error) in
            LoadingOverlay.shared.hideOverlayView()

            if success {
                self?.performSegue(withIdentifier: Constants.Storyboard.Segue.SignUpCompleteSegue, sender: nil)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Sign up failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - IBActions
    @IBAction func signUp(_ sender: UIButton?) {
        if !validateForm() {
            return
        }

        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
        performSmartCycleRegistration()
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signUp(nil)
        textField.resignFirstResponder()

        return true
    }
}
