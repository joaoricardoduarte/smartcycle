//
//  Branding.swift
//  Pause
//
//  Created by Joao Duarte on 25/07/2016.
//  Copyright © 2016 Joao Duarte. All rights reserved.
//

import UIKit

class Branding {

    class func fontMediumForSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size)!
    }

    class func makeImageRounded(image: UIImageView) {
        image.layer.cornerRadius = image.frame.size.width / 2
        image.layer.borderWidth = 0.0
        image.layer.borderColor = UIColor.clear.cgColor
    }
}
