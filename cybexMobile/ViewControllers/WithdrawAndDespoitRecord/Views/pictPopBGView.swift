//
//  pictPopBGView.swift
//  cybexMobile
//
//  Created by DKM on 2018/9/26.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import UIKit

class pictPopBGView: UIPopoverBackgroundView {

    override var arrowOffset: CGFloat {
        get {
            return self.arrowOffset
        }
        set {
            self.arrowOffset = newValue
        }
    }
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return self.arrowDirection
        }
        set {
            self.arrowDirection = newValue
        }
    }

    var arrowView: UIView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                                 size: CGSize(width: 60, height: 60)))
    var backgroundView: UIView

    override init(frame: CGRect) {
        backgroundView = UIView(frame: frame)
        backgroundView.backgroundColor = UIColor.purple
        arrowView.backgroundColor = UIColor.red
        super.init(frame: frame)
        backgroundColor = UIColor.red

        self.addSubview(arrowView)
        self.addSubview(backgroundView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setArrowOffset(offset: CGFloat) {
        arrowOffset = offset
    }
}

extension pictPopBGView {
    override class func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    override class func arrowBase() -> CGFloat {
        return 60
    }
    override class func arrowHeight() -> CGFloat {
        return 60
    }
}
