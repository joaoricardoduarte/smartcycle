//
//  LoadingOverlay.swift
//  SmartCycle
//
//  Created by Joao R DUARTE on 27/06/2017.
//  Copyright © 2017 Joao Duarte. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

public class LoadingOverlay {
    fileprivate var bgView = UIView()

    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }

    public func showOverlay(view: UIView) {
        if bgView.subviews.count == 0 {
            bgView.frame = view.frame
            bgView.backgroundColor = UIColor.black
            bgView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleHeight, .flexibleWidth]
            bgView.alpha = 0.7

            // Spinner
            let activityIndicatorView = DGActivityIndicatorView(type: .rotatingSandglass, tintColor: UIColor.white, size: 50)
            activityIndicatorView?.center = CGPoint(x: bgView.bounds.width / 2, y: bgView.bounds.height / 2)
            activityIndicatorView?.startAnimating()
            bgView.addSubview(activityIndicatorView!)
        }

        view.addSubview(bgView)
    }

    public func hideOverlayView() {
        bgView.removeFromSuperview()
    }
}
