//
//  CybexShowTitleView.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class CybexShowTitleView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var contentLable: UILabel!

    @objc fileprivate func updateHeight() {
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight() + 25
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        loadFromXIB()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

extension CybexShowTitleView: Views {
    var content: Any? {
        get {
            return self.contentLable.text
        }
        set {
            self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
        }
    }
}
