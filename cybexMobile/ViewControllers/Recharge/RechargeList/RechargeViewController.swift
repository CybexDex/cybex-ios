//
//  RechargeViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class RechargeViewController: BaseViewController {
  
  var selectedIndex : Int = 0
  
  @IBOutlet weak var tableView: UITableView!
  var coordinator: (RechargeCoordinatorProtocol & RechargeStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  func setupUI(){
    
    self.localized_text = R.string.localizable.account_trade.key.localizedContainer()
    let cell = String.init(describing:TradeCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
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

extension RechargeViewController {
  @objc func segmentTouch(_ data:[String:Any]){
    selectedIndex = data["selectedIndex"] as! Int
    print("segmentTouch")
  }
}
extension RechargeViewController:UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:TradeCell.self), for: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch selectedIndex {
    case 0:self.coordinator?.openRechargeDetail()
    case 1:self.coordinator?.openWithDrawDetail()
    default:
      break
    }
  }
}
