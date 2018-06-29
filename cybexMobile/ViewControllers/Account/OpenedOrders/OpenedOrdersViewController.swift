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
  
  func showEnterPassword(){
    let title = R.string.localizable.withdraw_unlock_wallet.key.localized()
    ShowManager.shared.setUp(title: title, contentView: CybexPasswordView(frame: .zero), animationType: .up_down)
    ShowManager.shared.delegate = self
    ShowManager.shared.showAnimationInView(self.view)
  }
  
  func showOrderInfo(){
    guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0), let asset = app_data.assetInfo[AssetConfiguration.CYB] else { return }
    startLoading()
    calculateFee(operation, focus_asset_id: AssetConfiguration.CYB, operationID: .limit_order_cancel) { [weak self](success, amount, assetId) in
      guard let `self` = self else {return}
      self.endLoading()
      if success,let order = self.order{
        let openedOrderDetailView = StyleContentView(frame: .zero)
        let ensure_title = order.isBuy ? R.string.localizable.cancle_openedorder_buy.key.localized() : R.string.localizable.cancle_openedorder_sell.key.localized()
        ShowManager.shared.setUp(title: ensure_title, contentView: openedOrderDetailView, animationType: .up_down)
        ShowManager.shared.showAnimationInView(self.view)
        ShowManager.shared.delegate = self
      
        if let baseInfo = app_data.assetInfo[order.sellPrice.base.assetID], let quoteInfo = app_data.assetInfo[order.sellPrice.quote.assetID],let pair = self.pair{
          var priceInfo = ""
          var amountInfo = ""
          var totalInfo = ""
          let feeInfo = amount.stringValue.formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade
          if baseInfo.id == pair.base{
            let baseAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
            let quoteAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
            totalInfo = baseAmount.stringValue + " " + baseInfo.symbol.filterJade
            amountInfo = quoteAmount.stringValue + " " + quoteInfo.symbol.filterJade
            priceInfo =  (baseAmount / quoteAmount).stringValue.formatCurrency(digitNum: baseInfo.precision) + " " + baseInfo.symbol.filterJade
          }else{
            let baseAmount  = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
            let quoteAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
            
            totalInfo = baseAmount.stringValue + " " + quoteInfo.symbol.filterJade
            amountInfo = quoteAmount.stringValue + " " + baseInfo.symbol.filterJade
            priceInfo =  (baseAmount / quoteAmount).stringValue.formatCurrency(digitNum: quoteInfo.precision) + " " + quoteInfo.symbol.filterJade
          }
          openedOrderDetailView.data = getOpenedOrderInfo(price: priceInfo, amount: amountInfo, total: totalInfo, fee: feeInfo, isBuy: order.isBuy)
        }
      }
    }
  }
  
  func switchContainerView() {
    containerView?.removeFromSuperview()
    
    containerView = pageType == .account ? AccountOpenedOrdersView() : MyOpenedOrdersView()
    self.view.addSubview(containerView!)
    if let account_view = self.containerView as? AccountOpenedOrdersView {
      account_view.data = nil
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
    if let order = data["order"] as? LimitOrder {
      self.order = order
      if UserManager.shared.isLocked {
        showEnterPassword()
      }
      else {
        self.showOrderInfo()
      }
      
    }
  }
  
  func postCancelOrder() {
    if let order = self.order {
      self.startLoading()
      
      self.coordinator?.cancelOrder(order.id, callback: {[weak self] (success) in
        guard let `self` = self else { return }
        
        self.endLoading()
        ShowManager.shared.setUp(title_image: success ? R.image.icCheckCircleGreen.name : R.image.erro16Px.name, message: success ? R.string.localizable.cancel_create_success() : R.string.localizable.cancel_create_fail(), animationType: .up_down, showType: .alert_image)
        ShowManager.shared.showAnimationInView(self.view)
        ShowManager.shared.hide(2)
      })

    }
  }
}

extension OpenedOrdersViewController : ShowManagerDelegate{
  func returnEnsureAction() {
    ShowManager.shared.hide()
    self.postCancelOrder()
  }
  
  func returnUserPassword(_ sender : String){
    if let name = UserManager.shared.name.value {
      UserManager.shared.unlock(name, password: sender) { (success, _) in
        if success {
          ShowManager.shared.hide()
          self.showOrderInfo()
        }
        else {
          ShowManager.shared.data = R.string.localizable.recharge_invalid_password()
        }
        
      }
    }
  }
}


