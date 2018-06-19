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
  
  enum CELL_TYPE : Int{
    case RECHARGE
    case WITHDRAW
  }
  var selectedIndex : CELL_TYPE = .RECHARGE
  
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
    tableView.tableFooterView = UIView()
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
    selectedIndex = (data["selectedIndex"] as! Int) == 0 ? CELL_TYPE.RECHARGE : CELL_TYPE.WITHDRAW
    self.tableView!.reloadData()
  }
}
extension RechargeViewController:UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if selectedIndex == .WITHDRAW{
      if let data = UserManager.shared.balances.value{
        return data.count
      }
      return 0
    }
    return 20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:TradeCell.self), for: indexPath) as! TradeCell
    if selectedIndex == .WITHDRAW {
      if let data = UserManager.shared.balances.value{
        cell.setup(data[indexPath.row])
      }
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch selectedIndex.rawValue {
    case 0:
      self.coordinator?.openWithDrawDetail()
    case 1:
      if let data = UserManager.shared.balances.value{
        let info = data[indexPath.row]
        
        self.coordinator?.openRechargeDetail(info)
      }
    default:
      break
    }
  }
}
