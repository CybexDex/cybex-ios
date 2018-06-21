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
import TinyConstraints

protocol TradePair {
  var pariInfo : Pair {get set}
}


class TradeViewController: BaseViewController {
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var scrollViewLeading: NSLayoutConstraint!
  @IBOutlet weak var historUpDown: UIButton!
  @IBOutlet weak var businessHeightConstraint: NSLayoutConstraint!
  @IBOutlet var orderBookView: UIView!
  
  var isMoveMarketTrades : Bool = false
  
  var myOrdersLeading : Constraint!
  
  var chooseTitleView : UIView?
  var tradeTitltView : TradeNavTitleView!
  
  var coordinator: (TradeCoordinatorProtocol & TradeStateManagerProtocol)?
  
  var tradeHistory : TradeHistoryViewController!
  var businessVC   : BusinessViewController!
  var myOrdersView : MyOpenedOrdersView!
  
  var homeViewController : HomeViewController!
  var orderBookViewController : OrderBookViewController!
  
  var chooseViewConstraint : Constraint!
  
  var isMoving : Bool?
  
  var pair : Pair = Pair(base: AssetConfiguration.ETH, quote: AssetConfiguration.CYB){
    didSet{
      if self.chooseTitleView != nil {
        self.sendEventActionWith()
      }
      tradeTitltView.title.text = (app_data.assetInfo[pair.quote]?.symbol.filterJade)! + "/" + (app_data.assetInfo[pair.base]?.symbol.filterJade)!
      self.childViewControllers.forEach { (viewController) in
        if var viewController = viewController as? TradePair{
          viewController.pariInfo = pair
        }
      }
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupNavi()
    self.historUpDown.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
  }
  
  func setupUI(){
    self.automaticallyAdjustsScrollViewInsets = false
    let titlesView = CybexTitleView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 32))
    topView.addSubview(titlesView)
    
    titlesView.data = [R.string.localizable.trade_buy.key.localized(),
                       R.string.localizable.trade_sell.key.localized(),
                       R.string.localizable.trade_total.key.localized()]
    
    businessVC.pair = Pair(base: AssetConfiguration.CYB, quote: AssetConfiguration.ETH)
    tradeHistory.pair = Pair(base: AssetConfiguration.CYB, quote: AssetConfiguration.ETH)
   
    self.orderBookViewController = R.storyboard.main.orderBookViewController()!
    self.orderBookViewController.VC_TYPE = 2
    self.orderBookViewController.coordinator = OrderBookCoordinator(rootVC: self.navigationController as! BaseNavigationController)
    self.addChildViewController(self.orderBookViewController)
    self.orderBookView.addSubview(self.orderBookViewController.view)
    self.orderBookViewController.view.frame = self.orderBookView.bounds
    self.orderBookViewController.view.layoutIfNeeded()
    self.orderBookViewController.didMove(toParentViewController: self)
  }
  
  func setupNavi(){
    let rightBtn = UIBarButtonItem(image: UIImage(named: "icStarBorder23Px"), style: .done, target: self, action: #selector(rightAction(_ :)))
    self.navigationItem.rightBarButtonItem = rightBtn
    
    let leftBtn = UIBarButtonItem(image: UIImage(named: "icCandle"), style: .done, target: self, action: #selector(leftAction(_ :)))
    self.navigationItem.leftBarButtonItem = leftBtn
    
    tradeTitltView = TradeNavTitleView(frame: CGRect.zero)
    tradeTitltView.delegate = self
    self.navigationItem.titleView = tradeTitltView    
  }
  
  @objc override func rightAction(_ sender: UIButton){
    self.coordinator?.openMyHistory()
  }
  
  @objc override func leftAction(_ sender: UIButton){
    
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.orderBookViewController.pair = self.pair
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
  
  func moveToMyOpenedOrders(){
    myOrdersView    = MyOpenedOrdersView(frame: CGRect.zero)
    self.view.addSubview(myOrdersView)
    myOrdersLeading =  myOrdersView.leadingToTrailing(of: self.scrollView)
    myOrdersView.top(to: self.scrollView)
    myOrdersView.width(to: self.scrollView)
    myOrdersView.height(to:self.scrollView)
    myOrdersLeading.constant = -self.view.width
    self.myOrdersView.layoutIfNeeded()
    self.view.layoutIfNeeded()
    self.scrollViewLeading.constant = -self.view.width
    isMoving = true
    UIView.animate(withDuration: 0.3, animations: {
      self.myOrdersView.layoutIfNeeded()
      self.view.layoutIfNeeded()
    }) {(isFinished) in
      self.isMoving = false
    }
  }
  
  func moveToTradeView(isBuy:Bool){
    businessVC.vc_type = isBuy == true ? .BUY : .SELL
    if myOrdersView != nil{
      myOrdersLeading.constant = 0
      scrollViewLeading.constant = 0
      isMoving = true
      UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
      }) { (isFinished) in
        self.myOrdersView.removeFromSuperview()
        self.myOrdersView     = nil
        self.myOrdersLeading  = nil
        self.isMoving         = false
      }
    }
  }
  
  @IBAction func marketTradesUpDown(_ sender: UIButton) {
    sender.transform = CGAffineTransform(rotationAngle: isMoveMarketTrades == false ? 0 : CGFloat(Double.pi))
    if isMoveMarketTrades{
      businessHeightConstraint.constant = 360
    }else{
      businessHeightConstraint.constant = 0
    }
    self.view.layoutIfNeeded()
    self.isMoveMarketTrades = !self.isMoveMarketTrades
  }
  
  
  override func delete(_ sender: Any?) {
    print("delete TradeViewController")
  }
}

extension TradeViewController : TradeNavTitleViewDelegate{
  func sendEventActionWith(){
    if self.chooseTitleView != nil {
      // 移除
      chooseViewConstraint.constant = -self.view.height
      UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
      }) { (isFinished) in
        self.homeViewController.willMove(toParentViewController: self)
        self.homeViewController.view.removeFromSuperview()
        self.homeViewController.removeFromParentViewController()
        self.chooseTitleView?.removeFromSuperview()
        self.chooseTitleView = nil
      }
    }else{
      // 添加
      self.homeViewController = R.storyboard.main.homeViewController()!
      self.homeViewController.VC_TYPE = 2
      self.addChildViewController(self.homeViewController)
      self.chooseTitleView = UIView()
      self.chooseTitleView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
      self.view.addSubview(self.chooseTitleView!)
      
      self.chooseTitleView?.top(to:self.view)
      self.chooseTitleView?.leading(to:self.view)
      self.chooseTitleView?.trailing(to: self.view)
      self.chooseTitleView?.height(to: self.view)
      self.view.layoutIfNeeded()
      
      self.view.addSubview(self.homeViewController.view)
      self.homeViewController.view.leftToSuperview(nil, offset: 0, relation: .equal, priority: .required, isActive:true, usingSafeArea: true)
      chooseViewConstraint = self.homeViewController.view.topToSuperview(nil, offset: -self.view.height, relation: .equal, priority: .required, isActive:true, usingSafeArea: true)
      self.homeViewController.view.rightToSuperview(nil, offset: 0, relation: .equal, priority: .required, isActive:true, usingSafeArea: true)
      self.homeViewController.view.height(397)
      self.homeViewController.didMove(toParentViewController: self)
      self.view.layoutIfNeeded()
      chooseViewConstraint.constant = 0
      UIView.animate(withDuration: 0.3) {
        self.view.layoutIfNeeded()
      }
    }
  }
}



extension TradeViewController{
  @objc func sendBtnAction(_ data:[String:Any]){
    if isMoving == true{
      return
    }
    
    switch data["selectedIndex"] as! Int {
    case 0:moveToTradeView(isBuy:true)
    case 1:moveToTradeView(isBuy:false)
    case 2:moveToMyOpenedOrders()
    default:
      break
    }
  }
  
  
}
