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
  
  func switchContainerView() {
    containerView?.removeFromSuperview()
    
    containerView = pageType == .account ? AccountOpenedOrdersView() : MyOpenedOrdersView()
    self.view.addSubview(containerView!)
    
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
        postCancelOrder()
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
    
  }
  
  func returnUserPassword(_ sender : String){
    if let name = UserManager.shared.name {
      UserManager.shared.unlock(name, password: sender) { (success, _) in
        if success {
          ShowManager.shared.hide()
          self.postCancelOrder()
        }
        else {
          ShowManager.shared.data = R.string.localizable.recharge_invalid_password()
        }
        
      }
    }
  }
}


