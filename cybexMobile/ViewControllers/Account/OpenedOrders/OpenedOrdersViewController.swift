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
import TinyConstraints
import Localize_Swift

enum openedOrdersViewControllerPageType {
  case exchange
  case account
}

class OpenedOrdersViewController: BaseViewController {
  
  var coordinator: (OpenedOrdersCoordinatorProtocol & OpenedOrdersStateManagerProtocol)?
  
  var pageType:openedOrdersViewControllerPageType = .account
  
  var pair: Pair?{
    didSet{
      if let pair_order = self.containerView as? MyOpenedOrdersView {
        pair_order.data = self.pair
      }
    }
  }
  
  var containerView:UIView?
  var order:LimitOrder?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  
  func setupUI(){
    self.localized_text = R.string.localizable.openedTitle.key.localizedContainer()
    
    switchContainerView()
  }
  
  func setupEvent(){
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] notification in
      guard let `self` = self else { return }
      if let account_view = self.containerView as? MyOpenedOrdersView {
        
        account_view.sectionView.totalTitle.locali = R.string.localizable.my_opened_price.key.localized()
        account_view.sectionView.cybPriceTitle.locali = R.string.localizable.my_opened_filled.key.localized()
      }      
    })
  }
  
  func showOrderInfo(){
    guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0) else { return }
    startLoading()
    guard let pair = self.pair else {return}
    guard let order = self.order else {return}
    calculateFee(operation, focus_asset_id: order.isBuy ? pair.base : pair.quote, operationID: .limit_order_cancel) { [weak self](success, amount, assetId) in
      guard let `self` = self else {return}
      self.endLoading()
      
      guard let trade = self.parent as? TradeViewController, trade.selectedIndex == 2, self.isVisible else {
        return
      }
      
      if success,let order = self.order{
        let ensure_title = order.isBuy ? R.string.localizable.cancle_openedorder_buy.key.localized() : R.string.localizable.cancle_openedorder_sell.key.localized()
        
        if let baseInfo = app_data.assetInfo[order.sellPrice.base.assetID], let quoteInfo = app_data.assetInfo[order.sellPrice.quote.assetID],let pair = self.pair,let fee_info = app_data.assetInfo[assetId]{
          var priceInfo = ""
          var amountInfo = ""
          var totalInfo = ""
          let feeInfo = amount.doubleValue.string(digits: fee_info.precision) + " " + fee_info.symbol.filterJade
          if baseInfo.id == pair.base{
            let baseAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
            let quoteAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
            totalInfo = baseAmount.doubleValue.string(digits: baseInfo.precision) + " " + baseInfo.symbol.filterJade
            amountInfo = quoteAmount.doubleValue.string(digits: quoteInfo.precision) + " " + quoteInfo.symbol.filterJade
            priceInfo =  (baseAmount / quoteAmount).doubleValue.string(digits: baseInfo.precision) + " " + baseInfo.symbol.filterJade
          }else{
            let baseAmount  = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
            let quoteAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
            
            totalInfo = baseAmount.doubleValue.string(digits: quoteInfo.precision) + " " + quoteInfo.symbol.filterJade
            amountInfo = quoteAmount.doubleValue.string(digits: baseInfo.precision) + " " + baseInfo.symbol.filterJade
            priceInfo =  (baseAmount / quoteAmount).doubleValue.string(digits: quoteInfo.precision) + " " + quoteInfo.symbol.filterJade
          }
          
          self.showConfirm(ensure_title, attributes: getOpenedOrderInfo(price: priceInfo, amount: amountInfo, total: totalInfo, fee: feeInfo, isBuy: order.isBuy))
        }
      }
      else{
        self.showToastBox(false, message: R.string.localizable.withdraw_nomore.key.localized())
      }
    }
  }
  
  func switchContainerView() {
    containerView?.removeFromSuperview()
    
    containerView = pageType == .account ? AccountOpenedOrdersView() : MyOpenedOrdersView()
    self.view.addSubview(containerView!)
    if let account_view = self.containerView as? AccountOpenedOrdersView {
      account_view.data = nil
    }else{
      setupEvent()
    }
    containerView?.edgesToDevice(vc:self, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), priority: .required, isActive: true, usingSafeArea: true)
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

      if let account_view = self.containerView as? AccountOpenedOrdersView {
        account_view.data = nil
      }
      else if let pair_order = self.containerView as? MyOpenedOrdersView {
        pair_order.data = self.pair
      }

      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
}

extension OpenedOrdersViewController : TradePair {
  var pariInfo: Pair {
    get {
      return self.pair!
    }
    set {
      self.pair = newValue
    }
  }
}

extension OpenedOrdersViewController {
  @objc func cancelOrder(_ data: [String: Any]) {
    if self.isLoading() {
      return
    }
    if let order = data["order"] as? LimitOrder {
      self.order = order
      if UserManager.shared.isLocked {
        if self.isLoading(){
          return
        }
        showPasswordBox(R.string.localizable.withdraw_unlock_wallet.key.localized())
      }
      else {
        self.showOrderInfo()
      }
    }
  }
  
  func postCancelOrder() {
    // order.isBuy ? pair.base : pair.quote
    if let order = self.order ,let pair = self.pair {
      
      self.coordinator?.cancelOrder(order.id, fee_id:order.isBuy ? pair.base : pair.quote ,callback: {[weak self] (success) in
        guard let `self` = self else { return }
        
        self.endLoading()
        self.showToastBox(success, message: success ? R.string.localizable.cancel_create_success() : R.string.localizable.cancel_create_fail())
      })
      
    }
  }
  
  override func passwordDetecting() {
    self.startLoading()
  }
  
  override func passwordPassed(_ passed: Bool) {
    self.endLoading()
    
    if passed {
      showOrderInfo()
    }
    else {
      self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
    }
  }
  
  override func returnEnsureAction() {
    self.startLoading()
    ShowToastManager.shared.hide()
    self.postCancelOrder()
  }
}


