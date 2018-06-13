//
//  TradeViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class TradeViewController: BaseViewController {
    @IBOutlet weak var topView: UIView!
    
  var coordinator: (TradeCoordinatorProtocol & TradeStateManagerProtocol)?
  
  var tradeHistory : TradeHistoryViewController!
  var businessVC : BusinessViewController!
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI(){
    self.automaticallyAdjustsScrollViewInsets = false
    
    let titlesView = CybexTitleView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 32))
    topView.addSubview(titlesView)
    titlesView.data = ["买入","卖出","我的委单"]
    
    businessVC.pair = Pair(base: AssetConfiguration.CYB, quote: AssetConfiguration.ETH)
    tradeHistory.pair = Pair(base: AssetConfiguration.CYB, quote: AssetConfiguration.ETH)
    
    let rightBtn = UIBarButtonItem(title: "我的记录", style: .done, target: self, action: #selector(rightAction(_ :)))
    self.navigationItem.rightBarButtonItem = rightBtn
    
    let leftBtn = UIBarButtonItem(image: UIImage(named: "icCandle"), style: .done, target: self, action: #selector(leftAction(_ :)))
    self.navigationItem.leftBarButtonItem = leftBtn
    
//    let titleView = UIView(frame: CGRect(x: 100, y: 0, width: 100, height: 24))
//    titleView.backgroundColor = .red
//    
//    let label  = UILabel(frame: CGRect.zero)
//    label.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
//    label.textColor = .white
//    label.text = "CYB/ETH"
//    label.sizeToFit()
//
//    titleView.addSubview(label)
//    let imageV = UIImageView(frame: <#T##CGRect#>)
//    
//    self.navigationItem.titleView = titleView
    
  }
  
  @objc override func rightAction(_ sender: UIButton){
    self.coordinator?.openMyHistory()
  }
  
  @objc override func leftAction(_ sender: UIButton){
    
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "pushTradeHistoryViewController" {
      tradeHistory = segue.destination as! TradeHistoryViewController
      tradeHistory.coordinator = TradeHistoryCoordinator(rootVC: self.navigationController as! BaseNavigationController)
    }else if segue.identifier == "pushBusinessViewController" {
      businessVC = segue.destination as! BusinessViewController
      businessVC.coordinator = BusinessCoordinator(rootVC: self.navigationController as! BaseNavigationController)
    }
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
}

extension TradeViewController{
  @objc func sendBtnAction(_ data:[String:Any]){
    switch data["selectedIndex"] as! Int {
    case 0:print("买入")
    case 1:print("卖出")
    case 2:print("我的委单")
    default:
      break
    }
  }
}
