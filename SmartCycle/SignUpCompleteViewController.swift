//
//  SignUpCompleteViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 27/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//


class SignUpCompleteViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Sign Up Complete Page")
    }

    // MARK: - IBActions
    @IBAction func goBackToLoginPage(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
