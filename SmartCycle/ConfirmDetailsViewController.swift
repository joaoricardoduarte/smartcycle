//
//  ConfirmDetailsViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 02/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//


class ConfirmDetailsViewController: BaseViewController {
    @IBOutlet fileprivate weak var firstNameTextField: UITextField!
    @IBOutlet fileprivate weak var lastNameTextField: UITextField!
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var twitterTextField: UITextField!

    var bike: BikeItem?
    var bikeParkedItem: BikeParkedItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        populateUserData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Confirm Details on Report Missing Page")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    fileprivate func populateUserData() {
        if let user = UserManager.sharedInstance.user {
            firstNameTextField.text = user.firstName
            lastNameTextField.text = user.lastName
            emailTextField.text = user.email

            if let twitter = user.twitter {
                twitterTextField.text = twitter
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ReportTemsViewController {
            viewController.bike = bike
            viewController.bikeParkedItem = bikeParkedItem
        }
    }

    // MARK: - IBActions
    @IBAction func proceed(_ sender: UITapGestureRecognizer?) {
        if let user = UserManager.sharedInstance.user {
            user.firstName = (firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            user.lastName = (lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            user.email = (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            user.twitter = twitterTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        self.performSegue(withIdentifier: Constants.Storyboard.Segue.ReportTermsSegue, sender: nil)
    }
}

extension ConfirmDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        proceed(nil)
        textField.resignFirstResponder()

        return true
    }
}
