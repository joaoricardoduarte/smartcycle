//
//  ReportViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 29/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//


class ReportViewController: BaseViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var buttonLabel: UILabel!
    @IBOutlet private weak var proceedButton: UIButton!

    var bikeParkedItem: BikeParkedItem?

    fileprivate var isStageOne = true // Using this to define if user is on Missing Bike Page or Sorry Message Page

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Report Landing Page")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MissingBikeViewController {
            viewController.bikeParkedItem = bikeParkedItem
        }
    }

    // MARK: - IBActions
    @IBAction func reportMissing(_ sender: UITapGestureRecognizer) {
        if isStageOne {
            textLabel.text = NSLocalizedString("We are sorry that your bike is missing. If you follow the next steps we can help finding your bike by sharing its details with our smartcycle community", comment: "")
            buttonLabel.text = NSLocalizedString("PROCEED", comment: "")
            titleLabel.text = NSLocalizedString("MISSING BIKE", comment: "")
            proceedButton.isHidden = false
        } else if UserManager.sharedInstance.user?.bikes.count == 0 {
            let alert = UIAlertController(title: NSLocalizedString("No Bikes found in your profile", comment: ""), message: NSLocalizedString("To proceed, please go back to the profile page and add your bicycle details.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: Constants.Storyboard.Segue.MissingBikeSegue, sender: nil)
        }
        
        isStageOne = false
    }

    @IBAction func backModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
