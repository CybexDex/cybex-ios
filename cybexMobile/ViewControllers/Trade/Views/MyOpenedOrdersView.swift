//
//  MyOpenedOrdersView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class MyOpenedOrdersView: UIView {
    @IBOutlet weak var sectionView: LockupAssetsSectionView!
    @IBOutlet weak var tableView: UITableView!
    
  fileprivate func setup() {
    let name = UINib.init(nibName: String.init(describing:OpenedOrdersCell.self), bundle: nil)
    self.tableView.register(name, forCellReuseIdentifier: String.init(describing:OpenedOrdersCell.self))
    sectionView.totalTitle.locali = R.string.localizable.my_opened_price.key.localized()
    sectionView.cybPriceTitle.locali = R.string.localizable.my_opened_filled.key.localized()
    self.tableView.tableFooterView = UIView()
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

extension MyOpenedOrdersView : UITableViewDelegate,UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let orderes = UserManager.shared.limitOrder.value ?? []
    return orderes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:OpenedOrdersCell.self), for: indexPath) as! OpenedOrdersCell
    cell.Cell_Type = 0
    var orderes = UserManager.shared.limitOrder.value ?? []
    cell.setup(orderes[indexPath.row], indexPath: indexPath)
    return cell
  }
  
  
}
