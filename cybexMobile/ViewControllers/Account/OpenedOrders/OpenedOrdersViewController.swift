//
//  OpenedOrdersViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
class OpenedOrdersViewController: BaseViewController {
  @IBOutlet weak var segment: UISegmentedControl!
  
  @IBOutlet weak var tableView: UITableView!
  var headerView:OpenedOrdersHeaderView!
  
  var coordinator: (OpenedOrdersCoordinatorProtocol & OpenedOrdersStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  
  
  func setupUI(){
    headerView = OpenedOrdersHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 103))
    headerView.sectionTitleView.cybPriceTitle.locali = R.string.localizable.opened_order_value.key.localized()
    headerView.sectionTitleView.totalTitle.locali = R.string.localizable.opened_asset_amount.key.localized()
    
    tableView.tableHeaderView = headerView
    self.localized_text = R.string.localizable.openedTitle.key.localizedContainer()
    let cell = String.init(describing:OpenedOrdersCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)    
    tableView.separatorColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
    
    updateHeaderView()
  }
  
  func updateHeaderView() {
    guard let _ = UserManager.shared.limitOrder.value else { return }
    
    if segment.selectedSegmentIndex == 0 {
      headerView.totalValue_tip.localized_text = R.string.localizable.openedAllMoney.key.localizedContainer()
      headerView.data = (UserManager.shared.limitOrderValue / changeCYB_ETH().toDouble()! * app_data.eth_rmb_price).toString
    }
    else if segment.selectedSegmentIndex == 1 {
      headerView.totalValue_tip.localized_text = R.string.localizable.openedBuyMoney.key.localizedContainer()
      headerView.data = (UserManager.shared.limitOrder_buy_value / changeCYB_ETH().toDouble()! * app_data.eth_rmb_price).toString
    }
    else {
      headerView.totalValue_tip.localized_text = R.string.localizable.openedSellMoney.key.localizedContainer()
      headerView.data = ((UserManager.shared.limitOrderValue - UserManager.shared.limitOrder_buy_value) / changeCYB_ETH().toDouble()! * app_data.eth_rmb_price).toString
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
  }
  
  
  override func configureObserveState() {
    commonObserveState()
    
    UserManager.shared.limitOrder.asObservable().skip(1).subscribe(onNext: {[weak self] (balances) in
      guard let `self` = self else { return }
      self.updateHeaderView()
      self.tableView.reloadData()
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
}

extension OpenedOrdersViewController : UITableViewDataSource,UITableViewDelegate{
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var orderes = UserManager.shared.limitOrder.value ?? []
    if segment.selectedSegmentIndex == 1 {
      orderes = orderes.filter({$0.isBuy})
    }
    else if segment.selectedSegmentIndex == 2 {
      orderes = orderes.filter({!$0.isBuy})
    }
    
    return orderes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OpenedOrdersCell.self), for: indexPath) as! OpenedOrdersCell
    var orderes = UserManager.shared.limitOrder.value ?? []
    if segment.selectedSegmentIndex == 1 {
      orderes = orderes.filter({$0.isBuy})
    }
    else if segment.selectedSegmentIndex == 2 {
      orderes = orderes.filter({!$0.isBuy})
    }
    
    cell.setup(orderes[indexPath.row], indexPath: indexPath)
    
    return cell
  }
  
  
  
}

extension OpenedOrdersViewController {
  @IBAction func segmentClicked(_ sender: Any) {
    updateHeaderView()
    self.tableView.reloadData()
  }
}
