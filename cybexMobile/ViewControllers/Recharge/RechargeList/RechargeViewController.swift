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
  
  var data : [String]?
  override func viewDidLoad() {
    super.viewDidLoad()
    startLoading()
    self.coordinator?.fetchDepositIdsInfo()
    self.coordinator?.fetchWithdrawIdsInfo()
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
    
    self.coordinator?.state.property.depositIds.asObservable().skip(1).subscribe(onNext: { [weak self](ids) in
      guard let `self` = self else {return}
//      if self.selectedIndex == .RECHARGE {
      self.endLoading()
      self.data = self.fetchDepositData()
      self.tableView.reloadData()
//      }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
  
  func fetchDepositData() ->[String] {
    var ids : [String] = []
    if let balances = UserManager.shared.balances.value{
      let _ = balances.map({ids.append($0.asset_type)})
      var unique_ids = AssetConfiguration.shared.unique_ids
      for id in ids{
        if unique_ids.contains(id){
          unique_ids.removeAll(id)
        }
      }
      return ids + unique_ids
    }
    return AssetConfiguration.shared.unique_ids
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
    if let data = self.data{
      return data.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:TradeCell.self), for: indexPath) as! TradeCell
    if selectedIndex == .WITHDRAW {
      if let data = UserManager.shared.balances.value{
        cell.setup(data[indexPath.row])
      }
    }else{
      if let data = self.data{
        cell.setup(data[indexPath.row])
      }
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch selectedIndex.rawValue {
    case 0:
      if let data = self.coordinator?.state.property.depositIds.value {
        if let info = self.data{
          let id = info[indexPath.row]
          for trade in data{
            if trade.id == id{
              self.coordinator?.openWithDrawDetail(Trade(id: id, enable: true, message: ""))
              return
            }
          }
          self.coordinator?.openWithDrawDetail(Trade(id: id, enable: false, message: ""))
          return
        }
//        self.coordinator?.openWithDrawDetail(data[indexPath.row])
        
      }
    case 1:
      if let ids = self.coordinator?.state.property.withdrawIds.value {
        if let data = UserManager.shared.balances.value{
          let info = data[indexPath.row]
          for trade in ids{
            if trade.id == info.asset_type{
              self.coordinator?.openRechargeDetail(info,isWithdraw:true)
              return
            }
          }
          self.coordinator?.openRechargeDetail(info,isWithdraw:false)
        }
      }
    default:
      break
    }
  }
}
