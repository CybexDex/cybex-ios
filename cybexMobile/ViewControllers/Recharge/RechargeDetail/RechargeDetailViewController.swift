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
  
  var feeAssetId : String  = AssetConfiguration.CYB
  var available : Double = 0.0
  var requireAmount : String = ""
  var isWithdraw : Bool = false
  var isTrueAddress : Bool = false {
    didSet{
      if isTrueAddress != oldValue {
        self.changeWithdrawState()
      }
    }
  }
  var isAvalibaleAmount : Bool = false {
    didSet{
      if isAvalibaleAmount != oldValue {
        self.changeWithdrawState()
      }
    }
  }
  var trade : Trade? {
    didSet{
      if let trade = self.trade {
        self.balance = getBalanceWithAssetId(trade.id)
        self.precision = app_data.assetInfo[trade.id]?.precision
      }
    }
  }
  var balance : Balance? {
    didSet{
      if let balance = balance {
        self.available = getRealAmountDouble(balance.asset_type, amount: balance.balance)
      }
    }
  }
  var coordinator: (RechargeDetailCoordinatorProtocol & RechargeDetailStateManagerProtocol)?
  var precision : Int?
  override func viewDidLoad() {
    super.viewDidLoad()
    if let trade = self.trade, let trade_Info = app_data.assetInfo[trade.id]{
      self.title = trade_Info.symbol.filterJade + R.string.localizable.recharge_title.key.localized()
      if trade_Info.symbol.filterJade == "EOS"{
        self.contentView.addressView.name = R.string.localizable.eos_withdraw_account.key.localized()
        self.contentView.addressView.textplaceholder = R.string.localizable.eos_withdraw_account_placehold.key.localized()
      }
      self.startLoading()
      self.coordinator?.fetchWithDrawInfoData(trade_Info.symbol.filterJade)
    }
    setupUI()
    setupEvent()
  }
  
  func setupUI() {
    self.contentView.trade  = self.trade
    self.contentView.balance  = self.balance
  }
  
  func setupEvent() {
    
    self.contentView.amountView.btn.addTarget(self, action: #selector(addAllAmount), for: .touchUpInside)
    self.contentView.addressView.btn.addTarget(self, action: #selector(cleanAddress), for: .touchUpInside)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    self.contentView.withdraw.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self](tap) in
      guard let `self` = self else{ return }
      self.withDrawAction()
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: contentView.amountView.content, queue: nil) { [weak self](notification) in
      guard let `self` = self else {return}
      
      if let text = self.contentView.amountView.content.text,let amount = text.toDouble(),amount > 0,let balance = self.balance,let balance_info = app_data.assetInfo[balance.asset_type]{
        if let coordinator =  self.coordinator, let value = coordinator.state.property.data.value ,let precision = value.precision{
          self.precision = precision
          self.contentView.amountView.content.text = checkMaxLength(text, maxLength: value.precision ?? balance_info.precision)
        }else{
          self.contentView.amountView.content.text = checkMaxLength(text, maxLength: balance_info.precision)
        }
        self.checkAmountIsAvailable(amount)
      }else{
        if let text = self.contentView.amountView.content.text {
          self.contentView.amountView.content.text = text.substring(from: 0, length: text.count - 1)
        }
        self.isAvalibaleAmount = false
      }
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: contentView.addressView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{return}
      
      if let address = self.contentView.addressView.content.text, address.count > 0 {
        self.contentView.addressView.btn.isHidden = false
        let letterBegin = Guitar(pattern: "^([a-zA-Z0-9])")
        if !letterBegin.test(string: address){
          self.isTrueAddress = false
          self.contentView.errorView.isHidden = false
          self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key.localized()
          return
        }
        if let balance = self.balance ,let balance_info = app_data.assetInfo[balance.asset_type]{
          let assetName = balance_info.symbol.filterJade
          self.coordinator?.verifyAddress(assetName, address: address, callback: { (success) in
            if success{
              self.isTrueAddress = true
              self.contentView.errorView.isHidden = true
              if let amount = self.contentView.amountView.content.text,amount.count != 0,let amountDouble = amount.toDouble() {
                self.checkAmountIsAvailable(amountDouble)
              }
            }else{
              self.isTrueAddress = false
              self.contentView.errorView.isHidden = false
              self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key.localized()
            }
          })
        }
      }else{
        self.contentView.addressView.btn.isHidden = true
        self.isTrueAddress = false
      }
    }
  }
  
  func checkAmountIsAvailable(_ amount:Double) {
    if let data = self.coordinator?.state.property.data.value {
      self.isAvalibaleAmount  = false
      self.contentView.errorView.isHidden = false
      self.contentView.withdraw.isEnable = false
      if amount < data.minValue{
        self.contentView.errorL.locali = R.string.localizable.withdraw_min_value.key.localized()
      }else if amount > self.available || self.available < data.fee {
        self.contentView.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
      }else{
        self.isAvalibaleAmount = true
        self.contentView.errorView.isHidden = true
        self.setFinalAmount()
        if let addressText = self.contentView.addressView.content.text,addressText.count != 0,!self.isTrueAddress{
          self.contentView.errorView.isHidden = false
          self.contentView.errorL.locali = R.string.localizable.withdraw_address_fault.key.localized()
        }
      }
    }
  }
  
  func commonObserveState() {
    coordinator?.subscribe(errorSubscriber) { sub in
      return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    
    coordinator?.subscribe(loadingSubscriber) { sub in
      return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    
    self.coordinator?.state.property.data.asObservable().skip(1).subscribe(onNext: {[weak self] (withdrawInfo) in
      guard let `self` = self else { return }
      
      self.endLoading()
      if let data = withdrawInfo {
        if let precision = data.precision {
          self.precision = precision
        }
        if let trade = self.trade,let trade_info = app_data.assetInfo[trade.id],let precision = self.precision,let balance = self.balance{
          self.contentView.insideFee.text = data.fee.string(digits: precision) + " " + trade_info.symbol.filterJade
          self.contentView.avaliableView.content.text = getRealAmountDouble(balance.asset_type, amount: balance.balance).string(digits: trade_info.precision) + " " + trade_info.symbol.filterJade
        }
        self.setFinalAmount()
        SwifterSwift.delay(milliseconds: 300) {
          self.changeWithdrawState()
        }
        self.contentView.amountView.textplaceholder = R.string.localizable.recharge_min.key.localized() + String(describing: data.minValue)
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    
    self.coordinator?.state.property.gatewayFee.asObservable().subscribe(onNext: { [weak self](result) in
      guard let `self` = self else{ return }
      self.endLoading()
      if let data = result, data.success,let feeInfo = app_data.assetInfo[data.0.asset_id]{
        let fee = data.0
        if let trade = self.trade ,let precision = self.precision ,feeInfo.id == trade.id{
          self.contentView.gateAwayFee.text = (fee.amount.toDouble()?.string(digits: precision))! + " " + feeInfo.symbol.filterJade
        }else{
          self.contentView.gateAwayFee.text = (fee.amount.toDouble()?.string(digits: feeInfo.precision))! + " " + feeInfo.symbol.filterJade
        }
        self.feeAssetId = AssetConfiguration.CYB != fee.asset_id ? fee.asset_id : AssetConfiguration.CYB
        self.setFinalAmount()
        SwifterSwift.delay(milliseconds: 300, completion: {
          self.changeWithdrawState()
        })
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  
  override func configureObserveState() {
    commonObserveState()
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func setFinalAmount(){
    if let text = self.contentView.amountView.content.text,let amount = Decimal(string: text){
      
      let (finalAmount,requireAmount) = (self.coordinator?.getFinalAmount(fee_id: self.feeAssetId, amount: amount, available: self.available))!
      self.requireAmount = requireAmount
      if finalAmount.doubleValue > 0,let balance = self.balance, let balance_info = app_data.assetInfo[balance.asset_type],let precision = self.precision{
        self.contentView.finalAmount.text = finalAmount.doubleValue.string(digits: precision) + " " + balance_info.symbol.filterJade
      }
    }
  }
}

extension RechargeDetailViewController{
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
      if self.isLoading(){
        return
      }
      if ShowToastManager.shared.showView != nil {
        return
      }
      showPasswordBox(R.string.localizable.withdraw_unlock_wallet.key.localized())
      return
    }
    if !UserManager.shared.isWithDraw{
      showToastBox(false, message: R.string.localizable.withdraw_miss_authority.key.localized())
      return
    }else {
      if self.isTrueAddress, self.isAvalibaleAmount{
        if let _ = self.coordinator?.state.property.gatewayFee.value,let _ = self.coordinator?.state.property.data.value{
          self.contentView.withdraw.isEnable = true
        }else{
          if let trade = self.trade,let amount = self.contentView.amountView.content.text,let address = self.contentView.addressView.content.text{
            self.startLoading()
            self.coordinator?.getGatewayFee(trade.id, amount: amount, address: address)
          }
        }
      }else{
        self.contentView.withdraw.isEnable = false
      }
    }
  }
  
  @objc func cleanAddress() {
    self.contentView.addressView.content.text = ""
    self.isTrueAddress = false

  }
  
  @objc func addAllAmount(){
    if let balance = self.balance,let precision = self.precision{
      self.contentView.amountView.content.text = getRealAmount(balance.asset_type, amount: balance.balance).doubleValue.string(digits: precision)
      self.checkAmountIsAvailable(getRealAmount(balance.asset_type, amount: balance.balance).doubleValue)
      self.setFinalAmount()
    }
  }
  
  @objc func keyboardWillShow(){
    if self.contentView.addressView.content.isFirstResponder || self.contentView.amountView.content.isFirstResponder{
      self.contentView.feeView.isHidden       = true
      self.contentView.introduceView.isHidden = true
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func keyboardWillHidden(){
    self.contentView.feeView.isHidden       = false
    self.contentView.introduceView.isHidden = false
    self.view.layoutIfNeeded()
  }
  
  func withDrawAction(){
    if self.contentView.withdraw.isEnable,let trade = self.trade,let trade_info = app_data.assetInfo[trade.id]{
      let data = getWithdrawDetailInfo(addressInfo: self.contentView.addressView.content.text!, amountInfo: self.contentView.amountView.content.text! + " " + trade_info.symbol.filterJade, withdrawFeeInfo: self.contentView.insideFee.text!, gatewayFeeInfo: self.contentView.gateAwayFee.text!, receiveAmountInfo: self.contentView.finalAmount.text!)
      if self.isVisible{
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
    }else{
      if self.isVisible{
        self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
      }
    }
  }
}

extension RechargeDetailViewController {
  // 提现操作
  override func returnEnsureAction(){
    if let address = self.contentView.addressView.content.text{
      var gateway : Decimal = 0
      if let gatewayFee = self.coordinator?.state.property.gatewayFee.value{
        gateway = Decimal(string:gatewayFee.0.amount)!
      }
      startLoading()
  
      self.coordinator?.getObjects(assetId: (self.trade?.id)!,amount: self.requireAmount,address: address,fee_id: self.feeAssetId,fee_amount: gateway.stringValue,callback: {[weak self] (data) in
        guard let `self` = self else { return }
        self.endLoading()
        main {
          ShowToastManager.shared.hide()
          if self.isVisible{
            if String(describing: data) == "<null>"{
              self.showToastBox(true, message: R.string.localizable.recharge_withdraw_success.key.localized())
              SwifterSwift.delay(milliseconds: 100) {
                self.coordinator?.pop()
              }
            }else{
              self.showToastBox(false, message: R.string.localizable.recharge_withdraw_failed.key.localized())
            }
          }
        }
      })
    }
  }
}
