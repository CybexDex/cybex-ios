//
//  CybexAlertView.swift
//  Demo
//
//  Created by DKM on 2018/6/5.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit

class CybexAlertView: UIView {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!

    var data: Any? {
        didSet {
            if let data = data as? [String: String] {
                if let titleString = data["title"] {
                    title.text = titleString
                }

                if let messageString = data["message"] {
                    message.text = messageString
                }

                if let titleImageString = data["titleImage"] {
                    titleImage.image = UIImage(named: titleImageString)
                }
                updateHeight()
            }
        }
    }

    var isShowImage: Bool = false {
        didSet {
            if isShowImage == true {
                titleImage.isHidden = false
                title.isHidden      = true
            } else {
                titleImage.isHidden = true
                title.isHidden      = false
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        loadFromXIB()
    }

    func loadFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String.init(describing: type(of: self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

        view.layer.cornerRadius = 4.0
        view.clipsToBounds      = true
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}

extension CybexAlertView: Views {
    var content: Any? {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }
}
