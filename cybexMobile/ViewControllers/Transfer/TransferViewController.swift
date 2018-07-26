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
    Observable.combineLatest(self.coordinator!.state.property.accountValid.asObservable()).map { (arg0) -> Bool in
      }.bind(to: self.transferView.transferButton.isEnabled).disposed(by: disposeBag)
  }
  
  func setupUI() {
    self.title = R.string.localizable.transfer_title.key.localized()
    self.configRightNavButton(R.image.ic_records_24_px())
    transferView.balance = R.string.localizable.transfer_balance.key.localized() + "1000CYB"
    transferView.fee = "1.001 CYB"
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
}
