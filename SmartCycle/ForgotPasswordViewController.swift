//
//  ForgotPasswordViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 03/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//


class ForgotPasswordViewController: BaseViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var formsBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var textLabel: UILabel!

    fileprivate var recoverPasswordRequest = RecoverPasswordRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Forgot Password Page")
    }

    private func validateEmail() -> Bool {
        if !Utils.isValidEmail(email: emailTextField.text!) {
            let alert = UIAlertController(title: NSLocalizedString("Invalid email", comment: ""), message: NSLocalizedString("Please use a valid email.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return false
        }
        
        return true
    }

    // MARK: - IBActions
    @IBAction func resetPassword(_ sender: UIButton?) {
        if !validateEmail() {
            return
        }

        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

        recoverPasswordRequest.execute(email: emailTextField.text!) {[weak self] (success, error) in
            LoadingOverlay.shared.hideOverlayView()
            if success {
                let alert = UIAlertController(title: NSLocalizedString("Reset password", comment: ""), message: NSLocalizedString("An email has been sent to your inbox containing a link to reset your password.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                    _ = self?.navigationController?.popViewController(animated: true)
                }))

                self?.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Reset password failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resetPassword(nil)
        textField.resignFirstResponder()

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        formsBottomConstraint.constant = 160.0

        UIView.animate(withDuration: 0.3) {
            self.titleLabel.font = UIFont(name: self.titleLabel.font.fontName, size: 17.0)
            self.textLabel.font = UIFont(name: self.textLabel.font.fontName, size: 14.0)
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        formsBottomConstraint.constant = 70.0

        UIView.animate(withDuration: 0.3) {
            self.titleLabel.font = UIFont(name: self.titleLabel.font.fontName, size: 19.0)
            self.textLabel.font = UIFont(name: self.textLabel.font.fontName, size: 16.0)
            self.view.layoutIfNeeded()
        }
    }
}
