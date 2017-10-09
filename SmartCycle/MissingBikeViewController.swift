//
//  MissingBikeViewController.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 02/08/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

class MissingBikeViewController: BaseViewController {

    var bikeParkedItem: BikeParkedItem?

    static let CellIdentifier = "BikeTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setScreenName(name: "Select Missing Bike Page")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ConfirmDetailsViewController, let bike = sender as? BikeItem {
            viewController.bike = bike
            viewController.bikeParkedItem = bikeParkedItem
        }
    }
}

extension MissingBikeViewController: UITableViewDataSource {
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

        if let cell = cell as? BikeTableViewCell, let bikes = UserManager.sharedInstance.user?.bikes {
            cell.populateData(item: bikes[indexPath.section])
        }

        return cell
    }
}

extension MissingBikeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bikes = UserManager.sharedInstance.user?.bikes {
            self.performSegue(withIdentifier: Constants.Storyboard.Segue.ConfirmDetailsSegue, sender: bikes[indexPath.section])
        }
    }

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
