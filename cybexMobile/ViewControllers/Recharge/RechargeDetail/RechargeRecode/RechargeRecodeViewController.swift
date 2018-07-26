//
//  RechargeRecodeViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class RechargeRecodeViewController: BaseViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var coordinator: (RechargeRecodeCoordinatorProtocol & RechargeRecodeStateManagerProtocol)?
  
  var data : TradeRecord?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    if UserManager.shared.isLocked {
      self.showPasswordBox()
    }else {
      fetchDepositRecords()
    }
  }
  
  func setupUI() {
    self.title = R.string.localizable.deposit_list()
    let nibString = String(describing: RecodeCell.self)
    self.tableView.register(UINib(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
    self.view.showNoData(R.string.localizable.recode_nodata(), icon: R.image.img_no_records.name)
  }
  
  func fetchDepositRecords() {
    self.coordinator?.fetchRechargeRecodeList(UserManager.shared.name.value!, asset: "JADE.BAT", fundType: .DEPOSIT, size: 20, offset: 0, expiration: Int(Date().timeIntervalSince1970 + 600))
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
    
    self.coordinator?.state.property.data.asObservable().subscribe(onNext: { [weak self](data) in
      guard let `self` = self else { return }
      self.data = data
      if self.isVisible {
        self.tableView.reloadData()
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  override func configureObserveState() {
    commonObserveState()
  }
}

extension RechargeRecodeViewController : UITableViewDelegate,UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let data = self.data ,let records = data.records {
      return records.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellString = String(describing: RecodeCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: cellString, for: indexPath) as! RecodeCell
    if let data = self.data ,let records = data.records {
      cell.setup(records[indexPath.row], indexPath: indexPath)
    }
    return cell
  }
}
extension RechargeRecodeViewController {
  
  override func passwordDetecting() {
    self.startLoading()
  }
  
  override func passwordPassed(_ passed: Bool) {
    self.endLoading()
    if passed {
      self.startLoading()
      fetchDepositRecords()
    }else {
      if self.isVisible{
        self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
      }
    }
  }
}
