//
//  ShopViewController.swift
//  SmartCycle
//
//  Created by Joao Duarte on 26/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//


protocol ShopViewControllerDelegate: class {
    func hideShopDetailsPanel()
    func maximizeShopPanel(topConstraint: CGFloat)
}

class ShopViewController: BaseViewController {
    @IBOutlet private weak var shopImageView: UIImageView!
    @IBOutlet private weak var takeMeHereAddressLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var openingHoursTableView: UITableView!
    @IBOutlet private weak var openingHoursTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var openingHoursView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    weak var delegate: ShopViewControllerDelegate?

    static let CellIdentifier = "OpeningHoursTableViewCell"
    
    fileprivate var shopItem: StoreItem?
    fileprivate var ismaximized = false
    fileprivate var panelTopConstraint: CGFloat = 287
    fileprivate var panelOldContentOffset = CGPoint.zero
    fileprivate var panelTopConstraintRange: Range<CGFloat> = (CGFloat(80)..<CGFloat(287))
    fileprivate var panelMinimumRange: CGFloat = 80.0

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Shop Panel Page")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let panelContentSizeHeight = self.scrollView.contentSize.height
        let parentHeight = self.parent?.view.frame.height ?? 0

        if (panelContentSizeHeight + panelMinimumRange) < parentHeight {
            panelMinimumRange = parentHeight - panelContentSizeHeight + 5.0
            panelTopConstraintRange = (CGFloat(panelMinimumRange)..<CGFloat(287))
        }
    }

    func loadDetails(item: StoreItem) {
        panelTopConstraint = 287
        self.shopItem = item

//        loadOpeningHoursTable()

        if let address = self.shopItem?.address, let name = self.shopItem?.name, let location = self.shopItem?.location {
            takeMeHereAddressLabel.text = address.fullAddress()
            addressLabel.text = address.fullAddress()
            nameLabel.text = name

            if address.fullAddress().trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Utils.retriveLocationDetails(location: location) {[weak self] (address) in
                    if let address = address {
                        self?.shopItem?.address = address
                        self?.takeMeHereAddressLabel.text = address.fullAddress()
                        self?.addressLabel.text = address.fullAddress()
                    }
                }
            }
        }
    }

//    fileprivate func loadOpeningHoursTable() {
//        openingHoursTableViewHeightConstraint.constant = CGFloat(40.0 * Double((shopItem?.openingHours.count)!)) - 5
//        openingHoursView.layoutIfNeeded()
//        openingHoursTableView.reloadData()
//    }

    // MARK: - IBActions
    @IBAction func takeMeHere(_ sender: UITapGestureRecognizer) {
        if let location = shopItem?.location {
            openDirectionsToLocation(location: location, name: addressLabel.text!, walkingDirections: false)
        }
    }

    @IBAction func emailShop(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("No email available for this shop.", comment: ""), message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func callShop(_ sender: UIButton) {
        if let phoneNumber = shopItem?.telephone?.replacingOccurrences(of: " ", with: "") {
            guard let number = URL(string: "tel://" + phoneNumber) else { return }
            UIApplication.shared.open(number)
        }
    }

    @IBAction func openShopWebsite(_ sender: UIButton) {
        if let websiteUrl = shopItem?.website {
            let alert = UIAlertController(title: NSLocalizedString("This will open Safari to lauch the shop website.", comment: ""), message: nil, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default , handler:{ (UIAlertAction)in
                UIApplication.shared.open(URL(string: websiteUrl)!, options: [:], completionHandler: nil)
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler:nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ShopViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -50 {
            self.delegate?.hideShopDetailsPanel()
            ismaximized = false
            panelTopConstraint = 287
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta =  scrollView.contentOffset.y - panelOldContentOffset.y

        if delta > 0 && panelTopConstraint > panelTopConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
            panelTopConstraint -= delta
            panelTopConstraint = CGFloat.maximum(panelMinimumRange, panelTopConstraint)
            scrollView.contentOffset.y -= delta
            self.delegate?.maximizeShopPanel(topConstraint: panelTopConstraint)
        }

        panelOldContentOffset = scrollView.contentOffset
    }
}

extension ShopViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let results = shopItem?.openingHours.count {
//            return results
//        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).CellIdentifier, for: indexPath)

        if let cell = cell as? OpeningHoursTableViewCell {
            let item = shopItem?.openingHours[indexPath.row]
            if let weekday = item?.keys.first?.capitalized, let hours = item?.values.first {
                cell.populateData(weekday: weekday, time: hours)
            }
        }

        return cell
    }
}

extension ShopViewController: UITableViewDelegate {
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
