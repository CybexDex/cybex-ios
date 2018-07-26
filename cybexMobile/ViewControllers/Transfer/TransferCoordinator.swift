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
  
  func setAmount(_ amount: String)
  
  func setMemo(_ memo: String)
  
  func validAmount()
  
  func validAccount(_ account: String)
  
  func transfer(_ assetId: String, amount: String, address: String, fee_id: String, fee_amount: String, callback: @escaping (Any)->())
  
  func getGatewayFee(_ assetId: String, amount: String, memo: String)
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
    let balances = UserManager.shared.balances.value
    if let balances = balances {
      for balance in balances {
        if let info = app_data.assetInfo[balance.asset_type] {
          items.append(info.symbol.filterJade)
        }
      }
    }
    
    if let vc = R.storyboard.components.pickerViewController() {
      vc.items = items as AnyObject
      vc.selectedValue =  (0, 0)
      let coordinator = PickerCoordinator(rootVC: pickerCoordinator.rootVC)
      coordinator.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
        self?.store.dispatch(SetBalanceAction(balance: balances![picker.selectedRow(inComponent: 0)]))
      }
      vc.coordinator = coordinator
      
      newNav.pushViewController(vc, animated: true)
    }
  }
}

extension TransferCoordinator: TransferStateManagerProtocol {
  func transfer(_ assetId: String, amount: String, address: String, fee_id: String, fee_amount: String, callback: @escaping (Any) -> ()) {
    
  }
  
  
  func validAccount(_ account: String) {
    if let balance = self.state.property.balance.value {
      if let info = app_data.assetInfo[balance.asset_type] {
        verifyAddress(info.symbol.filterJade, address: account) {[weak self] (success) in
          guard let `self` = self else { return }
          self.store.dispatch(ValidAccountAction(isValid: success))
        }
      }
    }
  }
  
  func verifyAddress(_ assetName: String, address: String, callback: @escaping (Bool)->()){
    async {
      let data = try? await(GraphQLManager.shared.verifyAddress(assetName: assetName, address: address))
      main {
        if case let data?? = data {
          callback(data.valid)
        }else{
          callback(false)
        }
      }
    }
  }
  
  func setAmount(_ amount: String) {
    self.state.property.amount.accept(amount)
  }
  
  func setMemo(_ memo: String) {
    self.state.property.memo.accept(memo)
  }
  
  func validAmount() {
    if let balance = self.state.property.balance.value {
      getGatewayFee(balance.asset_type, amount: self.state.property.amount.value, memo: self.state.property.memo.value)
    }
  }
  
  func getGatewayFee(_ assetId: String, amount: String, memo: String) {
    let memo_key = self.state.property.memo.value
    if var amount = amount.toDouble(){
      let value = pow(10, (app_data.assetInfo[assetId]?.precision)!)
      amount = amount * Double(truncating: value as NSNumber)
      
      if let operationString = BitShareCoordinator.getTransterOperation(Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                                        to_user_id: Int32(getUserId((self.state.property.data.value?.gatewayAccount)!)),
                                                                        asset_id: Int32(getUserId(assetId)),
                                                                        amount: Int32(amount),
                                                                        fee_id: 0,
                                                                        fee_amount: 0,
                                                                        memo: memo,
                                                                        from_memo_key: UserManager.shared.account.value?.memo_key,
                                                                        to_memo_key: memo_key){
        
        calculateFee(operationString, focus_asset_id: assetId, operationID: .transfer) { (success, amount, fee_id) in
          log.debug(amount)
//          let dictionary = ["asset_id":fee_id,"amount":amount.stringValue]
//          self.store.dispatch(FetchGatewayFee(data:(Fee(JSON: dictionary)!,success:success)))
        }
      }
    }
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
