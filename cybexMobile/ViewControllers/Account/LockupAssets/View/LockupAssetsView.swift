//
//  LockupAssetsView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftTheme

class LockupAssetsView: UIView {
    enum Event: String {
        case clickLockupAssetsViewEvent
    }
    var data: Any? {
        didSet {
            guard let data = data as? LockupAssteData else { return }
            self.iconImgV.kf.setImage(with: URL(string: data.icon))
            nameL.text = data.name.filterJade
            if data.progress.formatCurrency(digitNum: 0) == "1" {
                self.claimBtn.isEnabled = true
                self.claimBtn.setBackgroundImage(R.image.btn_color_orange(), for: .normal)
                self.claimBtn.setTitle(R.string.localizable.lockup_asset_claim.key.localized(), for: .normal)
                self.claimBtn.setTitleColor(UIColor.white, for: .normal)
            }
            else {
                self.claimBtn.isEnabled = false
                self.claimBtn.setBackgroundImage(nil, for: .normal)
                self.claimBtn.setTitle(R.string.localizable.lockup_asset_locked.key.localized(), for: .normal)
                self.claimBtn.setTitleColor(ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo, for: .normal)
            }
            amountL.text = data.amount
            RMBCountL.text = data.RMBCount
            endTimeL.text = data.endTime
        }
    }
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var amountL: UILabel!
    @IBOutlet weak var RMBCountL: UILabel!
    @IBOutlet weak var endTimeL: UILabel!
    @IBOutlet weak var claimBtn: UIButton!
    fileprivate func setup() {
    }
    @IBAction func clickClaimAction(_ sender: UIButton) {
        guard let indexData = self.data as? LockupAssteData else { return }
        self.next?.sendEventWith(Event.clickLockupAssetsViewEvent.rawValue, userinfo: ["data": indexData])
    }
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }
    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }
    fileprivate func loadViewFromNib() {
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
