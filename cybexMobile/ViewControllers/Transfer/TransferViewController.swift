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
    }).disposed(by: disposeBag)
    
    //按钮状态监听
    Observable.combineLatest(self.coordinator!.state.property.accountValid.asObservable(),
                             self.coordinator!.state.property.amountValid.asObservable()).subscribe(onNext: {[weak self] (accountValid,amountValid) in
                              guard let `self` = self else { return }
                              self.transferView.buttonIsEnable = accountValid && amountValid
                              }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    //币种及余额监听
    self.coordinator!.state.property.balance.asObservable().subscribe(onNext: {[weak self] (balance) in
      guard let `self` = self else { return }
      if let balance = balance {
        if let info = app_data.assetInfo[balance.asset_type] {
          self.transferView.crypto = info.symbol.filterJade
          let realBalance = getRealAmountDouble(balance.asset_type, amount: balance.balance)
          self.transferView.balance = R.string.localizable.transfer_balance.key.localized() + String(format: "%f", realBalance) + (app_data.assetInfo[balance.asset_type]?.symbol.filterJade)!
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
  
  override func rightAction(_ sender: UIButton) {
    self.coordinator?.pushToRecordVC()
  }
}


extension TransferViewController {
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
