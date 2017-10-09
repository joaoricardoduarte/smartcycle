//
//  ReportTemsViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 02/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

class ReportTemsViewController: BaseViewController {
    @IBOutlet fileprivate weak var reportMissingLabel: UILabel!
    @IBOutlet fileprivate weak var termsSwitch: UISwitch!

    var bike: BikeItem?
    var bikeParkedItem: BikeParkedItem?

    fileprivate var reportMissingBikeRequest = ReportMissingBikeRequest()

    override func viewDidLoad() {
        super.viewDidLoad()

        termsSwitch.layer.cornerRadius = 16
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Report Submit Page")
    }

    // MARK: - IBActions
    @IBAction func switchValueDidChange(_ sender:UISwitch!) {
        reportMissingLabel.textColor = sender.isOn ? .white : .gray
    }

    @IBAction func proceed(_ sender: UITapGestureRecognizer) {
        if termsSwitch.isOn {
            if let parkId = bikeParkedItem?.parkId, let userId = UserManager.sharedInstance.user?.userId, let bikeId = bike?.model, let location = bikeParkedItem?.location {
                LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)

                reportMissingBikeRequest.execute(parkingId: parkId, userId: userId, bikeId: bikeId, location: location, {[weak self] (success, error) in
                    LoadingOverlay.shared.hideOverlayView()
                    if success {
                        let alert = UIAlertController(title: NSLocalizedString("Missing Bike Reported", comment: ""), message: NSLocalizedString("We have now shared yours and your bike details with the smartcycle community. Please remember that this is a report for the smartcycle community only. If you haven't done it already we advise that you report the missing bike in the nearest police station. We hope that you can find your bike.", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                            _ = self?.navigationController?.dismiss(animated: true, completion: {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.ReportMissingCompleteNotification), object: nil)
                            })
                        }))

                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: NSLocalizedString("Report missing bike failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
