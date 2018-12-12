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

class RechargeView: CybexBaseView {
    enum Event: String {
        case rechargeViewDidClicked
    }
    
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
                updateViewWithAssetName(tradeInfo)
            }
        }
    }
    
    var projectData: Any? {
        didSet{
            guard let projectInfo = projectData as? RechageWordVMData  else {
                return
            }
            self.introduce.locailStyle = StyleNames.withdrawIntroduce.rawValue
            self.introduce.locail = projectInfo.messageInfo
            self.updateHeight()
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

    override func setup() {
        super.setup()

        amountView.content.keyboardType = .decimalPad
        amountView.btn.setTitle(R.string.localizable.openedAll.key.localized(), for: .normal)
        self.withdraw.isEnable = false
        setupSubViewEvent()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.rechargeViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }

    func updateView() {
        if let balance = self.balance, let balanceInfo = appData.assetInfo[balance.assetType] {
            avaliableView.content.text = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).string(digits: balanceInfo.precision) + " " + balanceInfo.symbol.filterJade
        } else {
            if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
                avaliableView.content.text = "--" + tradeInfo.symbol.filterJade
            }
        }
    }
    
    func updateViewWithAssetName(_ tradeInfo: AssetInfo) {
        if tradeInfo.symbol.filterJade == AssetConfiguration.CybexAsset.EOS.rawValue {
            self.addressView.name = R.string.localizable.eos_withdraw_account.key
            self.addressView.content.placeholder = R.string.localizable.eos_withdraw_account_placehold.key.localized()
            self.addressView.content.setPlaceHolderTextColor(UIColor.steel50)

            if AddressManager.shared.getWithDrawAddressListWith(tradeInfo.id).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_account.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_account.key
            }
        }
        else if tradeInfo.symbol.filterJade == AssetConfiguration.CybexAsset.XRP.rawValue {
            self.memoView.title.text = "Tag"
            self.memoView.content.placeholder = R.string.localizable.withdraw_tag_placehold.key.localized()
            self.memoView.content.setPlaceHolderTextColor(UIColor.steel50)
            self.addressView.content.placeholder = R.string.localizable.withdraw_address_placehold.key.localized()
            self.addressView.content.setPlaceHolderTextColor(UIColor.steel50)
            if AddressManager.shared.getWithDrawAddressListWith(tradeInfo.id).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_address.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_address.key
            }
        }
        else {
            self.addressView.content.placeholder = R.string.localizable.withdraw_address_placehold.key.localized()
            self.addressView.content.setPlaceHolderTextColor(UIColor.steel50)
            self.memoView.isHidden = true
            if AddressManager.shared.getWithDrawAddressListWith(tradeInfo.id).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_address.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_address.key
            }
        }
    }
}
