//
//  CybexLabel.swift
//  Demo
//
//  Created by DKM on 2018/6/7.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit

class CybexLabel: UIView {

    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var content: UILabel!

    var data: Any? {
        didSet {
            if let data = data as? [String: String] {
                name.text    = data["name"]
                content.text = data["content"]
            }
            //            updateHeight()
        }
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.frame.size.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
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
        view.layer.cornerRadius = 4.0
        view.clipsToBounds = true
        addSubview(view)

        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
