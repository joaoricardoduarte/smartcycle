//
//  LoginViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 23/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: BaseViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    fileprivate var loginRequest = LoginRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Login Page")
    }

    // MARK: - IBActions
    @IBAction func login(_ sender: UIButton?) {
        if passwordTextField.text?.characters.count == 0 || emailTextField.text?.characters.count == 0 {
            let alert = UIAlertController(title: NSLocalizedString("Login", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        }

        LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

        loginRequest.execute(email: emailTextField.text!, password: passwordTextField.text!) {[weak self] (user, error) in
            LoadingOverlay.shared.hideOverlayView()
            if let error = error {
                let alert = UIAlertController(title: NSLocalizedString("Login failed", comment: ""), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } else if let user = user {
                UserManager.sharedInstance.loadUser(user: user)
                self?.performSegue(withIdentifier: Constants.Storyboard.Segue.HomeSegue, sender: nil)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login(nil)
        textField.resignFirstResponder()

        return true
    }
}
