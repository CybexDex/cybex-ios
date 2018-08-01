//
//  TransferViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import RxGesture
import SwifterSwift

class TransferViewController: BaseViewController {
  
  @IBOutlet weak var transferView: TransferView!
  var coordinator: (TransferCoordinatorProtocol & TransferStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    getFee()
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
  }
  
  override func configureObserveState() {
    commonObserveState()
    
    self.transferView.transferButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      self.transferComfirm()
    }).disposed(by: disposeBag)
    
    //按钮状态监听
    Observable.combineLatest(self.coordinator!.state.property.accountValid.asObservable(),
                             self.coordinator!.state.property.amountValid.asObservable()).subscribe(onNext: {[weak self] (accountValid,amountValid) in
                              guard let `self` = self else { return }
                              if let _ = self.coordinator?.state.property.balance.value, let transferAmount = self.coordinator?.state.property.amount.value.toDouble() {
                                self.transferView.buttonIsEnable = accountValid == .validSuccessed && amountValid && transferAmount > 0
                              } else {
                                self.transferView.buttonIsEnable = false
                              }
                              }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    //账户监听
    self.coordinator!.state.property.accountValid.asObservable().subscribe(onNext: {[weak self] (status) in
      self?.transferView.accountValidStatus = status
      if status == .validFailed && !(self?.coordinator?.state.property.account.value.isEmpty)! {
        self?.showToastBox(false, message: R.string.localizable.transfer_account_unexist.key.localized())
      }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    //余额监听
    self.coordinator!.state.property.amountValid.asObservable().subscribe(onNext: {[weak self] (result) in
      if !result, ((self?.coordinator?.state.property.fee.value) != nil) {
        self?.showToastBox(false, message: R.string.localizable.transfer_balance_unenough.key.localized())
      }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    //币种及余额监听
    self.coordinator!.state.property.balance.asObservable().subscribe(onNext: {[weak self] (balance) in
      guard let `self` = self else { return }
      if let balance = balance {
        if let info = app_data.assetInfo[balance.asset_type] {
          self.transferView.crypto = info.symbol.filterJade
          self.transferView.precision = info.precision
          let realBalance = getRealAmountDouble(balance.asset_type, amount: balance.balance)
          self.transferView.balance = R.string.localizable.transfer_balance.key.localized() + realBalance.string(digits: info.precision) + (app_data.assetInfo[balance.asset_type]?.symbol.filterJade)!
        }
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    //手续费监听
    self.coordinator!.state.property.fee.asObservable().subscribe(onNext: {[weak self] (result) in
      guard let `self` = self else { return }
      if let data = result,let feeInfo = app_data.assetInfo[data.asset_id]{
        let fee = data
        self.transferView.fee = (fee.amount.toDouble()?.string(digits: feeInfo.precision))! + " " + feeInfo.symbol.filterJade
      }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  func setupUI() {
    self.title = R.string.localizable.transfer_title.key.localized()
    self.configRightNavButton(R.image.ic_records_24_px())
  }
  
  func getFee() {
    self.coordinator?.validAmount()
  }
  
  func transferComfirm() {
    if let account = self.transferView.accountView.textField.text,
      let balance = self.coordinator?.state.property.balance.value,
      let amount = self.transferView.quantityView.textField.text,
      let memo = self.transferView.memoView.textView.text,
      let fee = self.coordinator?.state.property.fee.value {
      if let feeInfo = app_data.assetInfo[fee.asset_id] {
        let data = getTransferInfo(account, quanitity: amount + (app_data.assetInfo[balance.asset_type]?.symbol.filterJade)!, fee: (fee.amount.toDouble()?.string(digits: feeInfo.precision))! + " " + feeInfo.symbol.filterJade, memo: memo)
        showConfirm(R.string.localizable.withdraw_ensure_title.key.localized(), attributes: data)
      }
    }
  }
  
  override func rightAction(_ sender: UIButton) {
    self.coordinator?.pushToRecordVC()
  }
}


extension TransferViewController {
  override func returnEnsureAction() {
    if !UserManager.shared.isLocked {
      self.startLoading()
      self.coordinator?.transfer({ (data) in
        self.endLoading()
        main {
          ShowToastManager.shared.hide()
          if self.isVisible{
            if String(describing: data) == "<null>"{
              self.showToastBox(true, message: R.string.localizable.transfer_successed.key.localized())
              SwifterSwift.delay(milliseconds: 100) {
                self.coordinator?.pop()
              }
            }else{
              self.showToastBox(false, message: R.string.localizable.transfer_failed.key.localized())
            }
          }
        }
      })
    }
    else {
      self.showPasswordBox()
    }
  }
  
  @objc func selectCrypto(_ data: [String : Any]) {
    self.coordinator?.showPicker()
  }
  
  @objc func account(_ data: [String : Any]) {
    self.coordinator?.setAccount(data["content"] as! String)
  }
  
  @objc func amount(_ data: [String : Any]) {
    self.coordinator?.setAmount(data["content"] as! String)
  }
  
  @objc func memo(_ data: [String : Any]) {
    self.coordinator?.setMemo(data["content"] as! String)
  }
}
