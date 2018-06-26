//
//  BusinessTitleView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class BusinessTitleView: UIView {

  @IBOutlet weak var leftView: QuotesTitleView!
  @IBOutlet weak var tableView: UITableView!
  
  var selectedIndex:Int?
  
  var saveBaseIndex = 0
  
  var currentBaseIndex = 0 {
    didSet{
      self.tableView.reloadData()
      self.tableView.isHidden = false
    }
  }
  
  var data : Any?{
    didSet{
      
    }
  }
  
  func setup(){
    let cell = String.init(describing: BusinessTitleCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
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

extension BusinessTitleView:UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex]).count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: BusinessTitleCell.self), for: indexPath) as! BusinessTitleCell
    
    if let selectedIndex = self.selectedIndex,  selectedIndex == indexPath.row && saveBaseIndex == currentBaseIndex {
      cell.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.paleGrey.hexString(true)]
      cell.businessTitleCellView.paris.theme_textColor = [UIColor.pastelOrange.hexString(true), UIColor.pastelOrange.hexString(true)]
    }
    else {
      cell.theme_backgroundColor = [UIColor.darkTwo.hexString(true), UIColor.white.hexString(true)]
      cell.businessTitleCellView.paris.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
    }
    let markets = app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex])
    let data = markets[indexPath.row]
    cell.setup(data, indexPath: indexPath)
    
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
extension BusinessTitleView
{
  @objc func tagDidSelected(_ data : [String : Any]){
    if let index = data["selectedIndex"] as? Int, let save = data["save"] as? Bool {
      self.currentBaseIndex = index
      if save {
        saveBaseIndex = index
      }
    }
  }
}
