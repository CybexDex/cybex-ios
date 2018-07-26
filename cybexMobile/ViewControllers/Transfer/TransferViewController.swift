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
          self.transferView.balance = R.string.localizable.transfer_balance.key.localized() + String(format: "%f", realBalance)
        }
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    //手续费监听
    self.coordinator!.state.property.fee.asObservable().subscribe(onNext: {[weak self] (fee) in
      guard let `self` = self else { return }
      self.transferView.fee = fee
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  func setupUI() {
    self.title = R.string.localizable.transfer_title.key.localized()
    self.configRightNavButton(R.image.ic_records_24_px())
  }
  
  func setupEvent() {
    
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
    self.coordinator?.validAccount(data["content"] as! String)
  }
  
  @objc func amount(_ data: [String : Any]) {
    self.coordinator?.setAmount(data["content"] as! String)
  }
  
  @objc func memo(_ data: [String : Any]) {
    self.coordinator?.setMemo(data["content"] as! String)
  }
}
