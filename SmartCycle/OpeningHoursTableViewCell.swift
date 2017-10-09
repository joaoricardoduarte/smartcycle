//
//  OpeningHoursTableViewCell.swift
//  SmartCycle
//
//  Created by Joao Duarte on 20/07/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit

class OpeningHoursTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var weekdayLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!

    func populateData(weekday: String, time: String) {
        weekdayLabel.text = weekday
        timeLabel.text = time
    }
}
