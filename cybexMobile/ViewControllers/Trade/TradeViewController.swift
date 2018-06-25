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
  var tradeTitltView : TradeNavTitleView!
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  
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
      guard let base_info = app_data.assetInfo[pair.base], let quote_info = app_data.assetInfo[pair.quote] else { return }
      
      endLoading()
      if self.chooseTitleView != nil {
        self.sendEventActionWith()
      }
      
      tradeTitltView.title.text = quote_info.symbol.filterJade + "/" + base_info.symbol.filterJade
      self.childViewControllers.forEach { (viewController) in
        if var viewController = viewController as? TradePair{
          viewController.pariInfo = pair
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.startLoading()
    setupUI()
    
    self.pair = Pair(base: AssetConfiguration.ETH, quote: AssetConfiguration.CYB)
  }
  
  func setupUI(){
    setupNavi()
    
    let titlesView = CybexTitleView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 32))
    topView.addSubview(titlesView)
    
    titlesView.data = [R.string.localizable.trade_buy.key.localized(),
                       R.string.localizable.trade_sell.key.localized(),
                       R.string.localizable.trade_total.key.localized()]
    
  }
  
  func setupNavi(){
    configLeftNavButton(R.image.icStarBorder23Px())
    configRightNavButton(R.image.icCandle())
    
    tradeTitltView = TradeNavTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 64))
    tradeTitltView.delegate = self
    self.navigationItem.titleView = tradeTitltView    
  }
  
  @objc override func rightAction(_ sender: UIButton){
    
    if let baseIndex = AssetConfiguration.market_base_assets.index(of: pair.base), let index = app_data.filterQuoteAsset(pair.base).index(where: { (bucket) -> Bool in
      return bucket.base == pair.base && bucket.quote == pair.quote
    }) {
      self.coordinator?.openMarket(index: index, currentBaseIndex: baseIndex)
    }
  }
  
  @objc override func leftAction(_ sender: UIButton){
    self.coordinator?.openMyHistory()
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
  }
  
  func pageOffsetForChild(at index: Int) -> CGFloat {
    return CGFloat(index) * scrollView.bounds.width
  }
  
  func moveToMyOpenedOrders(){
    self.scrollView.setContentOffset(CGPoint(x: pageOffsetForChild(at: 2), y: 0), animated: true)
  }
  
  func moveToTradeView(isBuy:Bool){
    let index = isBuy ? 0 : 1
    self.scrollView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: true)
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
