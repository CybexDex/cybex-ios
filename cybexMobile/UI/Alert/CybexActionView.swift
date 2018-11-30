//
//  CybexActionView.swift
//  Demo
//
//  Created by DKM on 2018/6/5.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit

class CybexActionView: UIView {
    func setup() {

    }
    @IBOutlet weak var icon: UIImageView!

    @IBOutlet weak var message: UILabel!

    var data: Any? {
        didSet {
            if let data = data as? [String: String] {

                if let messageString = data["message"] {
                    message.text = messageString
                }

                if let titleImageString = data["titleImage"] {
                    icon.image = UIImage(named: titleImageString)
                }
                updateHeight()
            }
        }
    }

    override var  intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        loadFromXIB()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
    }

    func loadFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        addSubview(view)

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
extension CybexActionView: Views {
    var content: Any? {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }

}
