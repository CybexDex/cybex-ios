//
//  RechargeView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/4.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme
import Localize_Swift

class RechargeView: UIView {

    enum EventName: String {
        case addAllAmount
        case cleanAddress
    }

    var balance: Balance? {
        didSet {
            self.updateView()
        }
    }

    var trade: Trade? {
        didSet {
            if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
                self.introduce.content.attributedText = Localize.currentLanguage() == "en" ? trade.enInfo.set(style: StyleNames.withdraw_introduce.rawValue) : trade.cnInfo.set(style: StyleNames.withdraw_introduce.rawValue)

                updateViewWithAssetName(tradeInfo.id)
            }
        }
    }

    @IBOutlet weak var avaliableView: RechargeItemView!
    @IBOutlet weak var addressView: RechargeItemView!
    @IBOutlet weak var amountView: RechargeItemView!

    @IBOutlet weak var gateAwayFee: UILabel!
    @IBOutlet weak var insideFee: UILabel!

    @IBOutlet weak var finalAmount: UILabel!

    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorL: UILabel!

    @IBOutlet weak var feeView: UIView!

    @IBOutlet weak var introduceView: UIView!
    @IBOutlet weak var withdraw: Button!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var introduce: IntroduceView!

    @IBOutlet weak var memoView: RechargeItemView!

    func updateView() {
        if let balance = self.balance, let balanceInfo = appData.assetInfo[balance.asset_type] {
            avaliableView.content.text = getRealAmountDouble(balance.asset_type, amount: balance.balance).string(digits: balanceInfo.precision) +
                " " +
                balanceInfo.symbol.filterJade
        } else {
            if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
                avaliableView.content.text = "--" + tradeInfo.symbol.filterJade
            }
        }
    }

    func updateViewWithAssetName(_ name: String) {
        if name == AssetConfiguration.EOS {
            self.addressView.name = R.string.localizable.eos_withdraw_account.key
            self.addressView.textplaceholder = R.string.localizable.eos_withdraw_account_placehold.key

            if AddressManager.shared.getWithDrawAddressListWith(name).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_account.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_account.key
            }
        } else {
            self.memoView.isHidden = true
            if AddressManager.shared.getWithDrawAddressListWith(name).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_address.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_address.key
            }
        }
    }

    func setup() {
        amountView.content.keyboardType = .decimalPad
        amountView.btn.setTitle(R.string.localizable.openedAll.key.localized(), for: .normal)
        self.withdraw.isEnable = false
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
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func loadFromXIB() {
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
