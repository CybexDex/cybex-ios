//
//  HomeContentView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class HomeContentView: UIView {
  
  struct define {
    static let sectionHeaderHeight : Double = 71.0
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  var currentBaseIndex = 0 {
    didSet{
      self.tableView.reloadData()
      self.tableView.isHidden = false
    }
  }
    
  lazy var sectionHeader : HomeSectionHeaderView = {
    let sectionHeader = HomeSectionHeaderView(frame: CGRect(x: 0, y: 0, width: self.width, height: CGFloat(define.sectionHeaderHeight)))
    return sectionHeader
  }()
  
  
  var data : Any? {
    didSet{
      
    }
  }
  func setup(){
    let cell = String.init(describing: HomePairCell.self)
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

extension HomeContentView:UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex]).count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: HomePairCell.self), for: indexPath) as! HomePairCell
    let markets = app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex])
    let data = markets[indexPath.row]
    cell.setup(data, indexPath: indexPath)
    
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    return sectionHeader
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(define.sectionHeaderHeight)
  }
}

extension HomeContentView{
 
  @objc func tagDidSelected(_ data : [String : Any]){
    if let index = data["selectedIndex"] as? Int {
      self.currentBaseIndex = index
    }
  }
}


