//
//  SideMenuViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 25/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import SideMenu
import Cloudinary
import MessageUI

class SideMenuViewController: BaseViewController {
    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var emailLabel: UILabel!

    fileprivate let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: Constants.Keys.CloudinaryUsername, apiKey: Constants.Keys.CloudinaryAPIKey))
    fileprivate var removeBikeRequest = RemoveBikeRequest()

    static let CellIdentifier = "BikeTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        SideMenuManager.menuAnimationBackgroundColor = UIColor.clear
        SideMenuManager.menuEnableSwipeGestures = false
        Branding.makeImageRounded(image: profileImageView)

        populateUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Profile Landing Page")
    }

    fileprivate func populateUser() {
        if let user = UserManager.sharedInstance.user {
            if let profileImage = user.profileImage {
                profileImageView.image = profileImage
            } else if let publicId = user.profileCloudinaryPhotoId {
                Utils.loadCloudinaryImage(cloudinary: cloudinary, publicId: publicId, imageView: profileImageView)
            }

            nameLabel.text = user.firstName
            nameLabel.text = "\(user.firstName) \(user.lastName)"
            emailLabel.text = user.email
        }
    }

    fileprivate func performBikeDeletion(indexPath: IndexPath) {
        if let bike = UserManager.sharedInstance.user?.bikes[indexPath.section], let bikeId = bike.bikeId, let userId = UserManager.sharedInstance.user?.userId {
            LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
            removeBikeRequest.execute(bikeId: bikeId, userId: userId) {[weak self] (success, error) in
                LoadingOverlay.shared.hideOverlayView()
                if success {
                    let alert = UIAlertController(title: NSLocalizedString("Bike removed", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                        self?.updateBikeDeletionUI(bike: bike, indexPath: indexPath)
                    }))

                    self?.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Remove bike failed", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    fileprivate func updateBikeDeletionUI(bike: BikeItem, indexPath: IndexPath) {
        tableView.beginUpdates()
        UserManager.sharedInstance.removeBike(item: bike)
        tableView.deleteSections([indexPath.section], with: .automatic)
        tableView.endUpdates()
    }

    // MARK: - IBActions
    @IBAction func logout(_ sender: UIButton) {
        let alertController = UIAlertController(title: NSLocalizedString("Log out", comment: ""), message: NSLocalizedString("Are you sure you want to log out?", comment: ""), preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)

        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (_) in
            UserManager.sharedInstance.clearUser()

            if let loginViewController =  self.navigationController?.presentingViewController?.childViewControllers[1] as? LoginViewController {
                if let navController = self.navigationController?.presentingViewController as? UINavigationController {
                    navController.popToViewController(loginViewController, animated: true)
                }
            }
            self.dismiss(animated: true)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion:nil)
    }

    @IBAction func contactUs(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please make sure you have a valid email account set up and internet connection", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return
        } else {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["support@smartcycle.london"])
            composeVC.setSubject(NSLocalizedString("Smartcycle / iOS App Feedback", comment:""))
            self.present(composeVC, animated: true, completion: nil)
        }
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if let bikes = UserManager.sharedInstance.user?.bikes {
            return bikes.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).CellIdentifier, for: indexPath)

        if let cell = cell as? BikeTableViewCell, let bike = UserManager.sharedInstance.user?.bikes[indexPath.section] {
            cell.populateData(item: bike)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            performBikeDeletion(indexPath: indexPath)
        }
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
}

extension SideMenuViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let alert = UIAlertController(title: NSLocalizedString("Email sent", comment: ""), message: NSLocalizedString("~We will get back to you in 3 working days.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

        controller.dismiss(animated: true, completion: nil)
    }
}
