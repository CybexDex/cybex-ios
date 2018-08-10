//
//  AccountOpenedOrdersView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

class AccountOpenedOrdersView:UIView {
  enum event : String{
    case cancelOrder
  }
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segment: UISegmentedControl!
  var headerView:OpenedOrdersHeaderView!
  
  var data : Any?{
    didSet{
      updateHeaderView()
      self.tableView.reloadData()
    }
  }
  
  @IBAction func segmentDidClicked(_ sender: Any) {
    updateHeaderView()
    self.tableView.reloadData()
  }
  
  func updateHeaderView() {
    guard let _ = UserManager.shared.limitOrder.value else { return }
    
    if segment.selectedSegmentIndex == 0 {
      headerView.totalValue_tip.localized_text = R.string.localizable.openedAllMoney.key.localizedContainer()
      headerView.data = (UserManager.shared.limitOrderValue / changeCYB_ETH().toDouble()! * app_data.eth_rmb_price).string()
    }
    else if segment.selectedSegmentIndex == 1 {
      headerView.totalValue_tip.localized_text = R.string.localizable.openedBuyMoney.key.localizedContainer()
      headerView.data = (UserManager.shared.limitOrder_buy_value / changeCYB_ETH().toDouble()! * app_data.eth_rmb_price).string()
    }
    else {
      headerView.totalValue_tip.localized_text = R.string.localizable.openedSellMoney.key.localizedContainer()
      headerView.data = ((UserManager.shared.limitOrderValue - UserManager.shared.limitOrder_buy_value) / changeCYB_ETH().toDouble()! * app_data.eth_rmb_price).string()
    }
  }
  
  fileprivate func setup() {
    let cell = String.init(describing:OpenedOrdersCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
    tableView.separatorColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
    
    headerView = OpenedOrdersHeaderView(frame: CGRect(x: 0, y: 0, width: self.width, height: 103))
    
    headerView.sectionTitleView.cybPriceTitle.locali = R.string.localizable.my_opened_filled.key.localized()
    headerView.sectionTitleView.totalTitle.locali = R.string.localizable.my_opened_price.key.localized()
    tableView.tableHeaderView = headerView
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  fileprivate func updateHeight() {
    layoutIfNeeded()
    self.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  fileprivate func dynamicHeight() -> CGFloat {
    let lastView = self.subviews.last?.subviews.last
    return lastView!.bottom
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadViewFromNib()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadViewFromNib()
    setup()
  }
  
  fileprivate func loadViewFromNib() {
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
}

extension AccountOpenedOrdersView:UITableViewDelegate, UITableViewDataSource {
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
    cell.Cell_Type = 0
    
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

extension AccountOpenedOrdersView {
  @objc func cancleOrderAction(_ data: [String: Any]) {
    if let index = data["selectedIndex"] as? Int {
      
      var orderes = UserManager.shared.limitOrder.value ?? []
      
      if segment.selectedSegmentIndex == 1 {
        orderes = orderes.filter({$0.isBuy})
      }
      else if segment.selectedSegmentIndex == 2 {
        orderes = orderes.filter({!$0.isBuy})
      }
      
      let order = orderes[index]
      self.next?.sendEventWith(event.cancelOrder.rawValue, userinfo: ["order": order])
    }
  }
}
