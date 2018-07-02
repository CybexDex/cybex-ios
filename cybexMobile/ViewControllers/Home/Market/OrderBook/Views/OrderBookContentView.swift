//
//  OrderBookContentView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class OrderBookContentView: UIView {

    @IBOutlet weak var tableView: UITableView!
  
  
  var data : Any?{
    didSet{
      self.tableView.reloadData()
    }
  }
  
  fileprivate func setup() {
    let cell = String.init(describing: OrderBookCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)  }
  
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
extension OrderBookContentView:UITableViewDelegate,UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let data = self.data as? OrderBook{
      return min(20, max(data.asks.count, data.bids.count))
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OrderBookCell.self), for: indexPath) as! OrderBookCell
    if let data = self.data as? OrderBook{
      let asks = data.asks
      let bids = data.bids
      
      let max_asks = asks.count >= 20 ? 19 : asks.count - 1
      let max_bids = bids.count >= 20 ? 19 : bids.count - 1

      let max_asks_percent  = asks[optional:max_asks]?.volume_percent
      let max_bids_percent  = bids[optional:max_bids]?.volume_percent

      let asks_percent = asks[optional:indexPath.row]?.volume_percent
      let bids_percent = bids[optional:indexPath.row]?.volume_percent
      
      var percent_buy:Double? = nil
      var percent_sell:Double? = nil

      if let max_asks_percent = max_asks_percent, let asks_percent = asks_percent {
        percent_buy = asks_percent / max_asks_percent
      }
      if let max_bids_percent = max_bids_percent, let bids_percent = bids_percent {
        percent_sell = bids_percent / max_bids_percent
      }
      
      cell.setup((bids[optional:indexPath.row], asks[optional:indexPath.row], percent_sell, percent_buy), indexPath: indexPath)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
  }
}
