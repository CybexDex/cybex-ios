//
//  TransferCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Presentr

protocol TransferCoordinatorProtocol {
  func pushToRecordVC()
  
  func showPicker()
}

protocol TransferStateManagerProtocol {
  var state: TransferState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  func verifyAddress(_ assetName: String, address: String, callback: @escaping (Bool)->())
  
  func validAmount(_ balance: Balance, amount: NSString, memo: String)
  
  func transfer(_ assetId: String, amount: String, address: String, fee_id: String, fee_amount: String, callback: @escaping (Any)->())
}

class TransferCoordinator: AccountRootCoordinator {
  
  lazy var creator = TransferPropertyActionCreate()
  
  var store = Store<TransferState>(
    reducer: TransferReducer,
    state: nil,
    middleware:[TrackingMiddleware]
  )
}

extension TransferCoordinator: TransferCoordinatorProtocol {
  func pushToRecordVC() {
    let recordVC = R.storyboard.recode.transferListViewController()
    let coordinator = TransferListCoordinator(rootVC: self.rootVC)
    recordVC?.coordinator = coordinator
    self.rootVC.pushViewController(recordVC!, animated: true)
  }
  
  func showPicker() {
    let width = ModalSize.full
    let height = ModalSize.custom(size: 244)
    let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
    let customType = PresentationType.custom(width: width, height: height, center: center)
    
    let presenter = Presentr(presentationType: customType)
    presenter.dismissOnTap = true
    presenter.keyboardTranslationType = .moveUp
    
    let newNav = BaseNavigationController()
    let pickerCoordinator = PickerRootCoordinator(rootVC: newNav)
    self.rootVC.topViewController?.customPresentViewController(presenter, viewController: newNav, animated: true, completion: nil)
    
    var items = [String]()
    if let balances = UserManager.shared.balances.value {
      for balance in balances {
        if let trade = app_data.assetInfo[balance.asset_type] {
          items.append(trade.symbol.filterJade)
        }
      }
    }
    
    if let vc = R.storyboard.components.pickerViewController() {
      vc.items = items as AnyObject
      vc.selectedValue =  (0, 0)
      let coordinator = PickerCoordinator(rootVC: pickerCoordinator.rootVC)
      coordinator.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
        
      }
      vc.coordinator = coordinator
      
      newNav.pushViewController(vc, animated: true)
    }
  }
}

extension TransferCoordinator: TransferStateManagerProtocol {
  func transfer(_ assetId: String, amount: String, address: String, fee_id: String, fee_amount: String, callback: @escaping (Any) -> ()) {
    
  }
  
  func verifyAddress(_ assetName: String, address: String, callback: @escaping (Bool)->()){
    async {
      let data = try? await(GraphQLManager.shared.verifyAddress(assetName: assetName, address: address))
      main {
        if case let data?? = data {
          self.store.dispatch(ValidAccountAction(isValid: data.valid))
        }else{
          self.store.dispatch(ValidAmountAction(isValid: false))
        }
      }
    }
  }
  
  func validAmount(_ balance: Balance, amount: NSString, memo: String) {
    
  }
  
  var state: TransferState {
    return store.state
  }
  
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
  
}
