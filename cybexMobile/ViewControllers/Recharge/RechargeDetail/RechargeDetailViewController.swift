//
//  RechargeDetailViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift
import AwaitKit
import Guitar
import SwifterSwift

class RechargeDetailViewController: BaseViewController {
    
    @IBOutlet weak var contentView: RechargeView!
    
    var feeAssetId: String  = AssetConfiguration.CYB
    var available: Double = 0.0
    var requireAmount: String = ""
    var isWithdraw: Bool = false
    var isTrueAddress: Bool = false {
        didSet {
            if isTrueAddress != oldValue {
                self.changeWithdrawState()
            }
        }
    }
    var isAvalibaleAmount: Bool = false {
        didSet {
            if isAvalibaleAmount == true {
                self.changeWithdrawState()
            }
        }
    }
    
    var trade: Trade? {
        didSet {
            if let trade = self.trade {
                self.balance = getBalanceWithAssetId(trade.id)
                self.precision = appData.assetInfo[trade.id]?.precision
                self.isEOS = trade.id == AssetConfiguration.EOS
            }
        }
    }
    var balance: Balance? {
        didSet {
            if let balance = balance {
                self.available = getRealAmountDouble(balance.asset_type, amount: balance.balance)
            }
        }
    }
    var coordinator: (RechargeDetailCoordinatorProtocol & RechargeDetailStateManagerProtocol)?
    var precision: Int?
    var isEOS: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
            self.title = tradeInfo.symbol.filterJade + R.string.localizable.recharge_title.key.localized()
            
            self.startLoading()
            self.coordinator?.fetchWithDrawInfoData(tradeInfo.symbol.filterJade)
        }
        
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentView.trade  = self.trade
    }
    func setupUI() {
        self.contentView.trade  = self.trade
        self.contentView.balance  = self.balance
        
        self.configRightNavButton(R.image.icWithdrawNew24Px())
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openWithdrawRecodeList((self.trade?.id)!)
    }
    
    func setupEvent() {
        self.contentView.amountView.btn.rx.controlEvent(UIControl.Event.touchUpInside)
            .asControlEvent()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                if let balance = self.balance, let precision = self.precision {
                    self.contentView.amountView.content.text = getRealAmount(balance.asset_type, amount: balance.balance).string(digits: precision, roundingMode: .down)
                    self.checkAmountIsAvailable(getRealAmount(balance.asset_type, amount: balance.balance).doubleValue)
                    self.setFinalAmount()
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.contentView.addressView.btn.rx.controlEvent(UIControl.Event.touchUpInside)
            .asControlEvent()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                
                self.coordinator?.chooseOrAddAddress(self.trade!.id)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                if self.contentView.addressView.content.isFirstResponder || self.contentView.amountView.content.isFirstResponder {
                    self.contentView.feeView.isHidden       = true
                    self.contentView.introduceView.isHidden = true
                    self.view.layoutIfNeeded()
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                self.contentView.feeView.isHidden       = false
                self.contentView.introduceView.isHidden = false
                self.view.layoutIfNeeded()
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.contentView.withdraw.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self](_) in
            guard let `self` = self else { return }
            self.withDrawAction()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification, object: contentView.amountView.content)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                if let text = self.contentView.amountView.content.text,
                    var amount = text.toDouble(),
                    amount >= 0,
                    let balance = self.balance,
                    let balanceInfo = appData.assetInfo[balance.asset_type] {
                    
                    if let coordinator =  self.coordinator, let value = coordinator.state.property.data.value, let precision = value.precision {
                        self.precision = precision
                        self.contentView.amountView.content.text = checkMaxLength(text, maxLength: value.precision ?? balanceInfo.precision)
                    } else {
                        self.contentView.amountView.content.text = checkMaxLength(text, maxLength: balanceInfo.precision)
                    }
                    amount = self.contentView.amountView.content.text!.toDouble()!
                    self.checkAmountIsAvailable(amount)
                } else {
                    if let text = self.contentView.amountView.content.text {
                        self.contentView.amountView.content.text = text.substring(from: 0, length: text.count - 1)
                    }
                    self.isAvalibaleAmount = false
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification, object: contentView.addressView.content)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                if let address = self.contentView.addressView.content.text, address.count > 0 {
                    let letterBegin = Guitar(pattern: "^([a-zA-Z0-9])")
                    if !letterBegin.test(string: address) {
                        self.isTrueAddress = false
                        self.contentView.errorView.isHidden = false
                        self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key
                        self.contentView.addressView.addressState = .Fail
                        return
                    }
                    if let balance = self.balance, let balanceInfo = appData.assetInfo[balance.asset_type] {
                        let assetName = balanceInfo.symbol.filterJade
                        self.contentView.addressView.addressState = .Loading
                        
                        RechargeDetailCoordinator.verifyAddress(assetName, address: address, callback: { (success) in
                            if success {
                                self.isTrueAddress = true
                                self.contentView.addressView.addressState = .Success
                                self.contentView.errorView.isHidden = true
                                if let amount = self.contentView.amountView.content.text, amount.count != 0, let amountDouble = amount.toDouble() {
                                    self.checkAmountIsAvailable(amountDouble)
                                }
                            } else {
                                self.contentView.addressView.addressState = .Fail
                                self.isTrueAddress = false
                                self.contentView.errorView.isHidden = false
                                self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key
                            }
                        })
                    }
                } else {
                    self.contentView.addressView.addressState = .normal
                    self.isTrueAddress = false
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification, object: contentView.memoView.content)
            .asObservable()
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }
                guard let trade = self.trade, let amount = self.contentView.amountView.content.text, let address = self.contentView.addressView.content.text else { return }
                self.startLoading()
                self.coordinator?.getGatewayFee(trade.id, amount: amount, address: address, isEOS: self.isEOS)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.property.withdrawAddress.asObservable().subscribe(onNext: { [weak self](address) in
            guard let `self` = self, let address = address else { return }
            self.contentView.addressView.content.text = address.address
            self.contentView.addressView.addressState = .Success
            self.contentView.memoView.content.text = address.memo
            self.isTrueAddress = true
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func checkAmountIsAvailable(_ amount: Double) {
        if let data = self.coordinator?.state.property.data.value {
            self.contentView.errorView.isHidden = false
            self.contentView.withdraw.isEnable = false
            if amount < data.minValue {
                self.isAvalibaleAmount  = false
                self.contentView.errorL.locali = R.string.localizable.withdraw_min_value.key
            } else if amount > self.available || self.available < data.fee {
                self.isAvalibaleAmount  = false
                self.contentView.errorL.locali =  R.string.localizable.withdraw_nomore.key
            } else {
                self.isAvalibaleAmount = true
                self.contentView.errorView.isHidden = true
                self.setFinalAmount()
                if let addressText = self.contentView.addressView.content.text, addressText.count != 0, !self.isTrueAddress {
                    self.contentView.errorView.isHidden = false
                    self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key
                }
            }
        }
    }
    
    override func configureObserveState() {
        self.coordinator?.state.property.data.asObservable().skip(1).subscribe(onNext: {[weak self] (withdrawInfo) in
            guard let `self` = self, let data = withdrawInfo else { return }
            self.endLoading()
            if let precision = data.precision {
                self.precision = precision
            }
            
            if let trade = self.trade, let trade_info = appData.assetInfo[trade.id], let precision = self.precision, let balance = self.balance {
                self.contentView.insideFee.text = data.fee.string(digits: precision) + " " + trade_info.symbol.filterJade
                self.contentView.avaliableView.content.text = getRealAmountDouble(balance.asset_type, amount: balance.balance).string(digits: trade_info.precision) + " " + trade_info.symbol.filterJade
            }
            self.setFinalAmount()
            SwifterSwift.delay(milliseconds: 300) {
                self.changeWithdrawState()
            }
            self.contentView.amountView.textplaceholder = R.string.localizable.recharge_min.key.localized() + String(describing: data.minValue)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.property.gatewayFee.asObservable().subscribe(onNext: { [weak self](result) in
            guard let `self` = self else { return }
            self.endLoading()
            if let data = result, data.success, let feeInfo = appData.assetInfo[data.0.asset_id] {
                let fee = data.0
                if let trade = self.trade, let precision = self.precision, feeInfo.id == trade.id {
                    self.contentView.gateAwayFee.text = (fee.amount.toDouble()?.string(digits: precision))! + " " + feeInfo.symbol.filterJade
                } else {
                    self.contentView.gateAwayFee.text = (fee.amount.toDouble()?.string(digits: feeInfo.precision))! + " " + feeInfo.symbol.filterJade
                }
                self.feeAssetId = AssetConfiguration.CYB != fee.asset_id ? fee.asset_id : AssetConfiguration.CYB
                self.setFinalAmount()
                SwifterSwift.delay(milliseconds: 300, completion: {
                    self.changeWithdrawState()
                })
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        (self.contentView.memoView.content.rx.text.orEmpty <-> self.coordinator!.state.property.memo).disposed(by: disposeBag)
    }
    
    func setFinalAmount() {
        guard let text = self.contentView.amountView.content.text, let amount = Decimal(string: text) else { return }
        guard let (finalAmount, requireAmount) = self.coordinator?.getFinalAmount(feeId: self.feeAssetId, amount: amount, available: self.available) else { return }
        self.requireAmount = requireAmount
        guard finalAmount.doubleValue > 0,
            let balance = self.balance,
            let balanceInfo = appData.assetInfo[balance.asset_type],
            let precision = self.precision else { return }
        self.contentView.finalAmount.text = finalAmount.doubleValue.string(digits: precision) + " " + balanceInfo.symbol.filterJade
    }
}



extension RechargeDetailViewController {
    /*
     1 所有的状态判断都在这个方法
     2 显示不同的状态提示框
     3 币种可提现  解锁钱包  权限  输入额度  地址
     */
    func changeWithdrawState() {
        if self.isWithdraw == false {
            if let trade = self.trade {
                self.showToastBox(false, message: Localize.currentLanguage() == "en" ? trade.enMsg : trade.cnMsg)
            }
            return
        }
        if UserManager.shared.isLocked {
            if self.isLoading() {
                return
            }
            if ShowToastManager.shared.showView != nil {
                return
            }
            showPasswordBox(R.string.localizable.withdraw_unlock_wallet.key.localized())
            return
        }
        if !UserManager.shared.isWithDraw {
            showToastBox(false, message: R.string.localizable.withdraw_miss_authority.key.localized())
            return
        } else {
            if self.isTrueAddress, self.isAvalibaleAmount {
                if let _ = self.coordinator?.state.property.gatewayFee.value, let _ = self.coordinator?.state.property.data.value {
                    self.contentView.withdraw.isEnable = true
                } else {
                    if let trade = self.trade, let amount = self.contentView.amountView.content.text, let address = self.contentView.addressView.content.text {
                        self.startLoading()
                        self.coordinator?.getGatewayFee(trade.id, amount: amount, address: address, isEOS: self.isEOS)
                    }
                }
            } else {
                self.contentView.withdraw.isEnable = false
            }
        }
    }
    
    func withDrawAction() {
        self.view.endEditing(true)
        if self.contentView.addressView.addressState != .Success {
            return
        }
        if self.contentView.withdraw.isEnable, let trade = self.trade, let tradeInfo = appData.assetInfo[trade.id] {
            let data = getWithdrawDetailInfo(addressInfo: self.contentView.addressView.content.text!,
                                             amountInfo: self.contentView.amountView.content.text! + " " + tradeInfo.symbol.filterJade,
                                             withdrawFeeInfo: self.contentView.insideFee.text!,
                                             gatewayFeeInfo: self.contentView.gateAwayFee.text!,
                                             receiveAmountInfo: self.contentView.finalAmount.text!,
                                             isEOS: self.isEOS,
                                             memoInfo: self.contentView.memoView.content.text!)
            if self.isVisible {
                showConfirm(R.string.localizable.withdraw_ensure_title.key.localized(), attributes: data)
            }
        }
    }
    
    override func passwordDetecting() {
        startLoading()
    }
    
    override func passwordPassed(_ passed: Bool) {
        endLoading()
        if passed {
            ShowToastManager.shared.hide()
            self.changeWithdrawState()
        } else {
            
            if self.isVisible {
                self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
            }
        }
    }
    
    override func cancelImageAction(_ sender: CybexTextView) {
        if sender.title.isHidden == true {
            self.coordinator?.pop()
        }
    }
}

extension RechargeDetailViewController {
    // 提现操作
    override func returnEnsureAction() {
        guard let address = self.contentView.addressView.content.text, let gatewayFee = self.coordinator?.state.property.gatewayFee.value
            else { return }
        startLoading()
        self.coordinator?.getObjects(assetId: (self.trade?.id)!,
                                     amount: self.requireAmount,
                                     address: address,
                                     feeId: self.feeAssetId,
                                     feeAmount: gatewayFee.0.amount,
                                     isEOS: self.isEOS,
                                     callback: {[weak self] (data) in
                                        guard let `self` = self else { return }
                                        self.endLoading()
                                        main {
                                            ShowToastManager.shared.hide()
                                            if self.isVisible {
                                                if String(describing: data) == "<null>"{
                                                    
                                                    if AddressManager.shared.containAddressOfWithDraw(address, currency: self.trade!.id).0 == false {
                                                        self.showConfirmImage(R.image.icCheckCircleGreen.name,
                                                                              title: R.string.localizable.withdraw_success_title.key.localized(),
                                                                              content: R.string.localizable.withdraw_success_content.key.localized())
                                                    } else {
                                                        self.showToastBox(true, message: R.string.localizable.recharge_withdraw_success.key.localized())
                                                        SwifterSwift.delay(milliseconds: 100) {
                                                            self.coordinator?.pop()
                                                        }
                                                    }
                                                } else {
                                                    self.showToastBox(false, message: R.string.localizable.recharge_withdraw_failed.key.localized())
                                                }
                                            }
                                        }
        })
    }
    
    override func returnEnsureImageAction() {
        if let address = self.contentView.addressView.content.text,
            let memo = self.contentView.memoView.content.text,
            let trade = self.trade {
            let withdrawAddress = WithdrawAddress(id: AddressManager.shared.getUUID(), name: "", address: address, currency: trade.id, memo: memo)
            self.coordinator?.openAddAddressWithAddress(withdrawAddress)
        }
    }
}
