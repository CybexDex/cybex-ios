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
import Localize_Swift

protocol TradePair {
  var pariInfo : Pair {get set}
  
  func refresh()
}

extension TradePair {
  func refresh() {
    
  }
}


class TradeViewController: BaseViewController {
  var tradeTitltView : TradeNavTitleView!
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  
  var titlesView : CybexTitleView?
  var chooseTitleView : UIView?//mask
  
  var selectedIndex:Int = 0 {
    didSet {
      switch selectedIndex  {
      case 0:moveToTradeView(isBuy:true)
      case 1:moveToTradeView(isBuy:false)
      case 2:moveToMyOpenedOrders()
      default:
        break
      }
    }
  }
  
  var coordinator: (TradeCoordinatorProtocol & TradeStateManagerProtocol)?
  
  var pair : Pair = Pair(base: AssetConfiguration.ETH, quote: AssetConfiguration.CYB){
    didSet{
      if self.chooseTitleView != nil {
        self.sendEventActionWith()
      }
      getPairInfo()
      refreshView()
    }
  }
  
  var info:(base: AssetInfo, quote:AssetInfo)? {
    didSet {
      if oldValue == nil && info != nil {//弱网到请求到数据刷新
        refreshView()
      }
    }
  }
  
  var isfirstRefresh : Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.startLoading()
    setupUI()
    setupEvent()
    
    self.pair = Pair(base: AssetConfiguration.ETH, quote: AssetConfiguration.CYB)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
    if app_data.data.value.count == 0 {
      return
    }
    
    if self.isVisible {
      self.getPairInfo()
      self.refreshView()
    }
  }
  
  func setupUI(){
    setupNavi()
    
    titlesView = CybexTitleView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 32))
    topView.addSubview(self.titlesView!)
    
    self.titlesView!.data = [R.string.localizable.trade_buy.key.localized(),
                             R.string.localizable.trade_sell.key.localized(),
                             R.string.localizable.trade_open_orders.key.localized()]
    
  }
  
  func setupEvent(){
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else {return}
      self.titlesView!.data = [R.string.localizable.trade_buy.key.localized(),
                               R.string.localizable.trade_sell.key.localized(),
                               R.string.localizable.trade_open_orders.key.localized()]
      self.rightNavButton?.setTitle(R.string.localizable.my_history_title.key.localized(), for: .normal)
    })
  }
  
  deinit{
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
  }
  
  func setupNavi(){
    configLeftNavButton(R.image.icCandle())
    configRightNavButton(R.image.ic_star_border_24_px())
    
    tradeTitltView = TradeNavTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
    tradeTitltView.delegate = self
    self.navigationItem.titleView = tradeTitltView    
  }
  
  func getPairInfo() {
    guard let base_info = app_data.assetInfo[pair.base], let quote_info = app_data.assetInfo[pair.quote] else {
      self.info = nil
      return
    }
    self.info = (base_info, quote_info)
  }
  
  @objc override func rightAction(_ sender: UIButton){
    self.coordinator?.openMyHistory()
  }
  
  @objc override func leftAction(_ sender: UIButton){
    if let baseIndex = AssetConfiguration.market_base_assets.index(of: pair.base), let index = app_data.filterQuoteAsset(pair.base).index(where: { (bucket) -> Bool in
      return bucket.base == pair.base && bucket.quote == pair.quote
    }) {
      self.coordinator?.openMarket(index: index, currentBaseIndex: baseIndex)
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
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    self.coordinator?.setupChildVC(segue)
  }
  
  override func configureObserveState() {
    commonObserveState()
    
    app_data.otherRequestRelyData.asObservable()
      .subscribe(onNext: { (s) in
        if app_data.data.value.count == 0 {
          return
        }
        
        if self.isVisible {
          self.getPairInfo()
          self.refreshView()
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  
  func refreshView() {
    main {
      guard let info = self.info else { return }
      self.endLoading()
      
      self.tradeTitltView.title.text = info.quote.symbol.filterJade + "/" + info.base.symbol.filterJade
      self.childViewControllers.forEach { (viewController) in
        if var viewController = viewController as? TradePair{
          viewController.pariInfo = self.pair
          if self.isfirstRefresh {
            viewController.refresh()
            self.isfirstRefresh = false
          }
        }
      }
    }
  }
  
  func pageOffsetForChild(at index: Int) -> CGFloat {
    return CGFloat(index) * scrollView.bounds.width
  }
  
  func moveToMyOpenedOrders(){
    if let viewController = childViewControllers[2] as? TradePair{
      viewController.refresh()
    }
    self.scrollView.setContentOffset(CGPoint(x: pageOffsetForChild(at: 2), y: 0), animated: false)
  }
  
  func moveToTradeView(isBuy:Bool){
    let index = isBuy ? 0 : 1
    if let viewController = childViewControllers[index] as? TradePair{
      viewController.refresh()
    }
    self.scrollView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: false)
  }
}

extension TradeViewController : TradeNavTitleViewDelegate {
  @discardableResult func sendEventActionWith() -> Bool {
    if app_data.data.value.count == 0 {
      return false
    }
    
    if self.chooseTitleView != nil {
      self.coordinator?.removeHomeVC {[weak self] in
        guard let `self` = self else { return }
        self.chooseTitleView?.removeFromSuperview()
        self.chooseTitleView = nil
        self.startLoading()
      }
    }else{
      self.chooseTitleView = UIView()
      self.chooseTitleView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
      self.view.addSubview(self.chooseTitleView!)
      
      self.chooseTitleView?.edges(to: self.view, insets: UIEdgeInsetsMake(0, 0, 0, 0), priority: .required, isActive: true)
      self.view.layoutIfNeeded()
      
      self.coordinator?.addHomeVC()
    }
    
    return true
  }
}

extension TradeViewController {
  @objc func sendBtnAction(_ data:[String:Any]) {
    selectedIndex = data["selectedIndex"] as! Int
  }
}
