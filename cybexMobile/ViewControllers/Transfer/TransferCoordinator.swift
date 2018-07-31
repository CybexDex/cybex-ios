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
  
  func pop()
}

protocol TransferStateManagerProtocol {
  var state: TransferState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  //获取转账收款人信息
  func getTransferAccountInfo()
  
  func setAccount(_ account: String)
  
  func setAmount(_ amount: String)
  
  func setMemo(_ memo: String)
  
  func validAmount()
  
  func validAccount()
  
  func checkAmount(_ transferAmount: Double)
  
  func transfer(_ callback: @escaping (Any)->())
  
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
    
    if items.count == 0 {
      items.append(R.string.localizable.balance_nodata())
    }
    
    if let vc = R.storyboard.components.pickerViewController() {
      vc.items = items as AnyObject
      vc.selectedValue =  (0, 0)
      let coordinator = PickerCoordinator(rootVC: pickerCoordinator.rootVC)
      coordinator.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
        guard let `self` = self else { return }
        self.getTransferAccountInfo()
        if let balance = balances,balance.count > 0 {
          self.store.dispatch(SetBalanceAction(balance: balances![picker.selectedRow(inComponent: 0)]))
        }
      }
      vc.coordinator = coordinator
      
      newNav.pushViewController(vc, animated: true)
    }
  }
  
  func pop() {
    self.rootVC.popViewController(animated: true, nil)
  }
}

extension TransferCoordinator: TransferStateManagerProtocol {
  func transfer(_ callback: @escaping (Any) -> ()) {
    getChainId { (id) in
      guard let balance = self.state.property.balance.value else {
        return
      }
      guard let to_account = self.state.property.to_account.value else {
        return
      }
      guard let fee = self.state.property.fee.value else {
        return
      }
      let amount = self.state.property.amount.value
      let requeset = GetObjectsRequest(ids: ["2.1.0"]) { (infos) in
        if let infos = infos as? (block_id:String,block_num:String){
          if var amount = amount.toDouble(){
            let value = pow(10, (app_data.assetInfo[balance.asset_type]?.precision)!)
            amount = amount * Double(truncating: value as NSNumber)
            
            let fee_amout = fee.amount.toDouble()! * Double(truncating: pow(10, (app_data.assetInfo[fee.asset_id]?.precision)!) as NSNumber)
            
            let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                              block_id: infos.block_id,
                                                              expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                              chain_id: id,
                                                              from_user_id: Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                              to_user_id: Int32(getUserId((self.state.property.to_account.value?.id)!)),
                                                              asset_id: Int32(getUserId(balance.asset_type)),
                                                              receive_asset_id: Int32(getUserId(balance.asset_type)),
                                                              amount: Int32(amount),
                                                              fee_id: Int32(getUserId(fee.asset_id)),
                                                              fee_amount: Int32(fee_amout),
                                                              memo: self.state.property.memo.value,
                                                              from_memo_key: UserManager.shared.account.value?.memo_key,
                                                              to_memo_key: to_account.memo_key)
            
            let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
              main {
                callback(data)
              }
            }, jsonstr: jsonstr!)
            CybexWebSocketService.shared.send(request: withdrawRequest)
          }
        }
      }
      CybexWebSocketService.shared.send(request: requeset)
    }
  }
  
  func validAccount() {
    if !self.state.property.account.value.isEmpty {
      UserManager.shared.checkUserName(self.state.property.account.value).done({[weak self] (exist) in
        main {
          guard let `self` = self else { return }
          self.store.dispatch(ValidAccountAction(isValid: exist))
          if exist {
            self.getTransferAccountInfo()
          }
        }
      }).cauterize()
    }
  }
  
  func setAccount(_ account: String) {
    self.state.property.account.accept(account)
    validAccount()
  }
  
  func setAmount(_ amount: String) {
    self.state.property.amount.accept(amount)
    validAmount()
  }
  
  func setMemo(_ memo: String) {
    self.state.property.memo.accept(memo)
    validAmount()
  }
  
  func validAmount() {
    let balance = self.state.property.balance.value
    getGatewayFee(balance?.asset_type ?? "", amount: self.state.property.amount.value, memo: self.state.property.memo.value)
  }
  
  func getTransferAccountInfo() {
    if self.state.property.accountValid.value {
      let requeset = GetFullAccountsRequest(name: self.state.property.account.value) { (response) in
        if let data = response as? FullAccount, let account = data.account {
          self.store.dispatch(SetToAccountAction(account: account))
        }
      }
      CybexWebSocketService.shared.send(request: requeset)
    }
  }
  
  func getGatewayFee(_ assetId: String, amount: String, memo: String) {
    if var amount = amount.toDouble() {
      let value = assetId.isEmpty ? 1 : pow(10, (app_data.assetInfo[assetId]?.precision)!)
      amount = amount * Double(truncating: value as NSNumber)
      checkAmount(amount)
      let from_user_id = UserManager.shared.account.value?.id ?? "0"
      let from_memo_key = UserManager.shared.account.value?.memo_key ?? ""
      let to_user_id = self.state.property.to_account.value?.id ?? "0"
      let to_memo_key = self.state.property.to_account.value?.memo_key ?? from_memo_key
      if let operationString = BitShareCoordinator.getTransterOperation(Int32(getUserId(from_user_id)),
                                                                        to_user_id: Int32(getUserId(to_user_id)),
                                                                        asset_id: Int32(getUserId(assetId)),
                                                                        amount: Int32(amount),
                                                                        fee_id: 0,
                                                                        fee_amount: 0,
                                                                        memo: memo,
                                                                        from_memo_key: from_memo_key,
                                                                        to_memo_key: to_memo_key){
        calculateFee(operationString, focus_asset_id: assetId, operationID: .transfer) { (success, amount, fee_id) in
          if success {
            let dictionary = ["asset_id":fee_id,"amount":amount.stringValue]
            self.store.dispatch(SetFeeAction(fee: Fee(JSON: dictionary)!))
            if let transferAmount = self.state.property.amount.value.toDouble() {
              self.checkAmount(transferAmount)
            } else {
              self.store.dispatch(ValidAmountAction(isValid: true))
            }
          } else {
            self.store.dispatch(ValidAmountAction(isValid: false))
          }
        }
      }
    }
  }
  
  func checkAmount(_ transferAmount: Double) {
    if let balance = self.state.property.balance.value,let totalAmount = balance.balance.toDouble() {
      var feeAmount: Double = 0
      if let fee = self.state.property.fee.value {
        if fee.asset_id == balance.asset_type {
          feeAmount = fee.amount.toDouble() ?? 0
          let value = fee.asset_id.isEmpty ? 1 : pow(10, (app_data.assetInfo[fee.asset_id]?.precision)!)
          feeAmount = feeAmount * Double(truncating: value as NSNumber)
        }
      }
      if transferAmount + feeAmount > totalAmount {
        self.store.dispatch(ValidAmountAction(isValid: false))
      } else {
        self.store.dispatch(ValidAmountAction(isValid: true))
      }
    } else {
      self.store.dispatch(ValidAmountAction(isValid: true))
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
