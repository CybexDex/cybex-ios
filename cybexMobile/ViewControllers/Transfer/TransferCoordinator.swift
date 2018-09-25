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
import NBLCommonModule

protocol TransferCoordinatorProtocol {
    func pushToRecordVC()
    
    func showPicker()
    
    func pop()
    
    func openAddTransferAddress(_ sender : TransferAddress)
    
    func reopenAction()
}

protocol TransferStateManagerProtocol {
    var state: TransferState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    //获取转账收款人信息
    func getTransferAccountInfo()
    
    func setAccount(_ account: String)
    
    func setAmount(_ amount: String ,canFetchFee : Bool)
    
    func setMemo(_ memo: String ,canFetchFee : Bool)
    
    func validAmount()
    
    func validAccount()
    
    func checkAmount(_ transferAmount: Double)
    
    func transfer(_ callback: @escaping (Any)->())
    
    func getGatewayFee(_ assetId: String, amount: String, memo: String)
    
    func chooseOrAddAddress()
    
    func dispatchAccountAction(_ type : AccountValidStatus) 

}

class TransferCoordinator: AccountRootCoordinator {
    
    lazy var creator = TransferPropertyActionCreate()
    
    var store = Store<TransferState>(
        reducer: TransferReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    
    override func register() {
        Broadcaster.register(TransferCoordinatorProtocol.self, observer: self)
        Broadcaster.register(TransferStateManagerProtocol.self, observer: self)
    }
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
        let balances = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
            return getRealAmountDouble(balance.asset_type, amount: balance.balance) != 0
        })
        if let balances = balances {
            for balance in balances {
                if let info = app_data.assetInfo[balance.asset_type] {
                    items.append(info.symbol.filterJade)
                }
            }
        }
        
        if items.count == 0 {
            items.append(R.string.localizable.balance_nodata.key.localized())
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
                    self.validAmount()
                }
            }
            vc.coordinator = coordinator
            
            newNav.pushViewController(vc, animated: true)
        }
    }
    
    func pop() {
        self.rootVC.popViewController(animated: true, nil)
    }
    
    func openAddAddress() {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.address_type = .transfer
            vc.asset = AssetConfiguration.CYB
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
    
    func chooseAddress() {
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
        
        let items = AddressManager.shared.getTransferAddressList()
        
        if let vc = R.storyboard.components.pickerViewController() {
            vc.items = items.map({ $0.name }) as AnyObject
            vc.selectedValue =  (0, 0)
            let coordinator = PickerCoordinator(rootVC: pickerCoordinator.rootVC)
            coordinator.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
                guard let `self` = self else { return }
                let selectedIndex = picker.selectedRow(inComponent: 0)
                self.store.dispatch(CleanToAccountAction())
                self.store.dispatch(ValidAccountAction(status: .validSuccessed))
                self.store.dispatch(ChooseAccountAction(account:items[selectedIndex]))
                self.getTransferAccountInfo()
            }
            vc.coordinator = coordinator
            
            newNav.pushViewController(vc, animated: true)
        }
    }
    
    func openAddTransferAddress(_ sender : TransferAddress) {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.address_type = .transfer
            vc.transferAddress = sender
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
    
    func reopenAction() {
        let transferVC = R.storyboard.recode.transferViewController()!
        let coordinator = TransferCoordinator(rootVC: self.rootVC)
        transferVC.coordinator = coordinator
        self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] = transferVC
    }
}

extension TransferCoordinator: TransferStateManagerProtocol {
    
    func dispatchAccountAction(_ type : AccountValidStatus) {
        self.store.dispatch(ValidAccountAction(status: type))
    }
    
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
            let requeset = GetObjectsRequest(ids: [objectID.dynamic_global_property_object.rawValue]) { (infos) in
                if let infos = infos as? (block_id:String,block_num:String){
                    if var amount = amount.toDouble() ,let assetInfo = app_data.assetInfo[balance.asset_type] ,let feeInfo = app_data.assetInfo[fee.asset_id]{
                        let value = pow(10, assetInfo.precision)
                        amount = amount * Double(truncating: value as NSNumber)
                        
                        guard let fee_amount = fee.amount.toDouble() ,let from_account = UserManager.shared.account.value ,let to_account = self.state.property.to_account.value else {
                                return
                        }
                        
                        let fee_amout = fee_amount * Double(truncating: pow(10, feeInfo.precision) as NSNumber)
                       
                        let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                          block_id: infos.block_id,
                                                                          expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                          chain_id: id,
                                                                          from_user_id: Int32(getUserId(from_account.id)),
                                                                          to_user_id: Int32(getUserId(to_account.id)),
                                                                          asset_id: Int32(getUserId(balance.asset_type)),
                                                                          receive_asset_id: Int32(getUserId(balance.asset_type)),
                                                                          amount: Int64(Int32(amount)),
                                                                          fee_id: Int32(getUserId(fee.asset_id)),
                                                                          fee_amount: Int64(fee_amout),
                                                                          memo: self.state.property.memo.value,
                                                                          from_memo_key: from_account.memo_key,
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
            if let vc = self.rootVC.topViewController as? TransferViewController {
                vc.transferView.accountView.loading_state = .Loading
            }
            UserManager.shared.checkUserName(self.state.property.account.value).done({[weak self] (exist) in
                main {
                    guard let `self` = self else { return }
                    self.store.dispatch(ValidAccountAction(status: exist ? .validSuccessed : .validFailed))
                    if exist {
                        self.getTransferAccountInfo()
                    }
                }
            }).cauterize()
        }
    }
    
    func setAccount(_ account: String) {
        if !self.state.property.account.value.isEmpty,self.state.property.account.value != account {
            self.store.dispatch(ValidAccountAction(status: .unValided))
        }
        self.state.property.account.accept(account)
        validAccount()
    }
    
    func setAmount(_ amount: String ,canFetchFee : Bool) {
        self.state.property.amount.accept(amount)
        if canFetchFee {
            validAmount()
        }
    }
    
    func setMemo(_ memo: String ,canFetchFee : Bool) {
        self.state.property.memo.accept(memo)
        if canFetchFee {
            validAmount()
        }
    }
    
    func validAmount() {
        let balance = self.state.property.balance.value
        getGatewayFee(balance?.asset_type ?? "", amount: self.state.property.amount.value, memo: self.state.property.memo.value)
    }
    
    func getTransferAccountInfo() {
        if self.state.property.accountValid.value == .validSuccessed {
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
            let from_user_id = UserManager.shared.account.value?.id ?? "0"
            let from_memo_key = UserManager.shared.account.value?.memo_key ?? ""
            let to_user_id = self.state.property.to_account.value?.id ?? "0"
            let to_memo_key = self.state.property.to_account.value?.memo_key ?? from_memo_key
            if let operationString = BitShareCoordinator.getTransterOperation(Int32(getUserId(from_user_id)),
                                                                              to_user_id: Int32(getUserId(to_user_id)),
                                                                              asset_id: Int32(getUserId(assetId)),
                                                                              amount: 0,
                                                                              fee_id: 0,
                                                                              fee_amount: 0,
                                                                              memo: memo,
                                                                              from_memo_key: from_memo_key,
                                                                              to_memo_key: to_memo_key){
                calculateFee(operationString, focus_asset_id: assetId, operationID: .transfer) { (success, amount, fee_id) in
                    let dictionary = ["asset_id":fee_id,"amount":amount.stringValue]
                    self.store.dispatch(SetFeeAction(fee: Fee(JSON: dictionary)!))
                    if success {
                        if var transferAmount = self.state.property.amount.value.toDouble() {
                            let value = assetId.isEmpty ? 1 : pow(10, (app_data.assetInfo[assetId]?.precision)!)
                            transferAmount = transferAmount * Double(truncating: value as NSNumber)
                            self.checkAmount(transferAmount)
                        } else {
                            self.store.dispatch(ValidAmountAction(isValid: true))
                        }
                    } else {
                        if let transferAmount = self.state.property.amount.value.toDouble(), transferAmount != 0 {
                            self.store.dispatch(ValidAmountAction(isValid: false))
                        }
                        //            self.store.dispatch(ValidAmountAction(isValid: false))
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
    
    func chooseOrAddAddress() {
        if AddressManager.shared.getTransferAddressList().count == 0 {
            self.openAddAddress()
        }
        else {
            self.chooseAddress()
        }
    }
    
}
