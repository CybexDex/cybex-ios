//
//  TransferDetailViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class TransferDetailViewController: BaseViewController {
  
    @IBOutlet weak var headerView: TransferTopView!
    @IBOutlet weak var contentView: TransferContentView!
    
    var coordinator: (TransferDetailCoordinatorProtocol & TransferDetailStateManagerProtocol)?
  
  var data : TransferRecordViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    self.title = R.string.localizable.transfer_detail()
    self.headerView.data = data
    self.contentView.data = data
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
    
  }
}
