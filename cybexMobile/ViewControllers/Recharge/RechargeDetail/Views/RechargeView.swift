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
                self.introduce.content.attributedText = Localize.currentLanguage() == "en" ?
                    trade.enInfo.set(style: StyleNames.withdrawIntroduce.rawValue) :
                    trade.cnInfo.set(style: StyleNames.withdrawIntroduce.rawValue)
                
                updateViewWithAssetName(tradeInfo)
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
            avaliableView.content.text = getRealAmountDouble(balance.assetType, amount: balance.balance).string(digits: balanceInfo.precision) + " " + balanceInfo.symbol.filterJade
        } else {
            if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
                avaliableView.content.text = "--" + tradeInfo.symbol.filterJade
            }
        }
    }
    
    func updateViewWithAssetName(_ tradeInfo: AssetInfo) {
        if tradeInfo.symbol.filterJade == "EOS" {
            self.addressView.name = R.string.localizable.eos_withdraw_account.key
            self.addressView.textplaceholder = R.string.localizable.eos_withdraw_account_placehold.key
            
            if AddressManager.shared.getWithDrawAddressListWith(tradeInfo.id).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_account.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_account.key
            }
        }
        else if tradeInfo.symbol.filterJade == "XRP" {
            self.memoView.title.text = "Tag"
            self.memoView.content.placeholder = R.string.localizable.withdraw_tag_placehold.key.localized()
            self.memoView.content.setPlaceHolderTextColor(UIColor.steel50)
        }
        else {
            self.memoView.isHidden = true
            if AddressManager.shared.getWithDrawAddressListWith(tradeInfo.id).count == 0 {
                self.addressView.btn.locali = R.string.localizable.add_address.key
            } else {
                self.addressView.btn.locali = R.string.localizable.choose_address.key
            }
        }
    }
}
