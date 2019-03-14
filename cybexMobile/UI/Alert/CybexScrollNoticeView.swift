//
//  CybexScrollNoticeView.swift
//  cybexMobile
//
//  Created by koofrank on 2019/2/26.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation

class CybexScrollNoticeView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    let didConfirmNotTip = Delegate<Void, Void>()
    
    func setup() {
        self.title.locali = R.string.localizable.contest_notice_title.key
        self.leftButton.locali = R.string.localizable.contest_notice_not_tip.key
        self.rightButton.locali = R.string.localizable.contest_notice_close.key

        let str = R.string.localizable.contest_notice.key.localized()
        self.content.attributedText = str.set(style: StyleNames.bold14With24.rawValue)
    }

    @discardableResult
    class func show() -> CybexScrollNoticeView {
        let v = CybexScrollNoticeView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 1000))
        UIApplication.shared.keyWindow?.addSubview(v)
        return v
    }

    @IBAction func leftButtonClicked(_ sender: Any) {
        didConfirmNotTip.call()
        self.removeFromSuperview()
    }

    @IBAction func rightButtonClicked(_ sender: Any) {
        self.removeFromSuperview()
    }

    override var intrinsicContentSize: CGSize {
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
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
        setup()
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
