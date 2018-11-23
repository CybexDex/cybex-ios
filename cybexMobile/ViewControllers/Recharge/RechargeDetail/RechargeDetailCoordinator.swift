//
//  RechargeDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift
import Presentr
import cybex_ios_core_cpp

protocol RechargeDetailCoordinatorProtocol {
    func pop()
    func openWithdrawRecodeList(_ assetId: String)
    func openAddAddressWithAddress(_ withdrawAddress: WithdrawAddress)
}

protocol RechargeDetailStateManagerProtocol {
    var state: RechargeDetailState { get }

    func fetchWithDrawInfoData(_ assetName: String)
    static func verifyAddress(_ assetName: String, address: String, callback:@escaping (Bool) -> Void)
    func getGatewayFee(_ assetId: String, amount: String, address: String, isEOS: Bool)
    func getObjects(assetId: String,
                    amount: String,
                    address: String,
                    feeId: String,
                    feeAmount: String,
                    isEOS: Bool,
                    callback:@escaping (Any) -> Void)
    func getFinalAmount(feeId: String, amount: Decimal, available: Double) -> (Decimal, String)

    func chooseOrAddAddress(_ sender: String)
}

class RechargeDetailCoordinator: NavCoordinator {
    var store = Store<RechargeDetailState>(
        reducer: rechargeDetailReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension RechargeDetailCoordinator: RechargeDetailCoordinatorProtocol {
    func pop() {
        self.rootVC.popViewController(animated: true)
    }

    func openAddAddressWithAddress(_ withdrawAddress: WithdrawAddress) {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.withdrawAddress = withdrawAddress
            vc.asset = withdrawAddress.currency
            vc.popActionType = .selectVC
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func openWithdrawRecodeList(_ assetId: String) {
        if let vc = R.storyboard.recode.rechargeRecodeViewController() {
            vc.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
            vc.recordType = .WITHDRAW
            vc.assetInfo = appData.assetInfo[assetId]
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func showPicker(_ asset: String) {
        let width = ModalSize.full
        let height = ModalSize.custom(size: 244)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let presenter = Presentr(presentationType: customType)
        presenter.dismissOnTap = true
        presenter.keyboardTranslationType = .moveUp

        let items = AddressManager.shared.getWithDrawAddressListWith(asset)
        var context = PickerContext()
        context.items = items.map({ $0.name }) as AnyObject
        context.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
            guard let `self` = self else { return }
            let selectedIndex =  picker.selectedRow(inComponent: 0)
            self.store.dispatch(SelectedAddressAction(data: items[selectedIndex]))
        }

        presentVC(PickerCoordinator.self, animated: true, context: context, navSetup: nil) { (top, target) in
            top.customPresentViewController(presenter, viewController: target, animated: true)
        }
    }

    func openAddAddress(_ asset: String) {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.addressType = .withdraw
            vc.asset = asset
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}
extension RechargeDetailCoordinator: RechargeDetailStateManagerProtocol {
    var state: RechargeDetailState {
        return store.state
    }

    func fetchWithDrawInfoData(_ assetName: String) {
        async {
            let data = try? await(GraphQLManager.shared.getWithdrawInfo(assetName: assetName))
            main {
                if case let data?? = data {
                    self.getWithdrawAccountInfo(data.gatewayAccount)
                    self.store.dispatch(FetchWithdrawInfo(data: data))
                }
            }
        }
    }

    func getWithdrawAccountInfo(_ userID: String) {
        let requeset = GetFullAccountsRequest(name: userID) { (response) in
            if let data = response as? FullAccount, let account = data.account {
                self.store.dispatch(FetchWithdrawMemokey(data: account.memoKey))
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }

    func getGatewayFee(_ assetId: String, amount: String, address: String, isEOS: Bool) {
        if let memoKey = self.state.memoKey.value {
            let name = appData.assetInfo[assetId]?.symbol.filterJade

            let memo = self.state.memo.value
            if var amount = amount.toDouble() {
                let value = pow(10, (appData.assetInfo[assetId]?.precision)!)
                amount = amount * Double(truncating: value as NSNumber)

                if let operationString = BitShareCoordinator.getTransterOperation(Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                                                  to_user_id: Int32(getUserId((self.state.data.value?.gatewayAccount)!)),
                                                                                  asset_id: Int32(getUserId(assetId)),
                                                                                  amount: Int64(amount),
                                                                                  fee_id: 0,
                                                                                  fee_amount: 0,
                                                                                  memo: isEOS ? GraphQLManager.shared.memo(name!, address: address + "[\(memo)]") :
                                                                                    GraphQLManager.shared.memo(name!, address: address),
                                                                                  from_memo_key: UserManager.shared.account.value?.memoKey,
                                                                                  to_memo_key: memoKey) {
                    calculateFee(operationString, focusAssetId: assetId, operationID: .transfer) { (success, amount, feeId) in
                        let dictionary = ["asset_id": feeId, "amount": amount.stringValue]
                        guard let fee = Fee.deserialize(from: dictionary) else { return }
                        self.store.dispatch(FetchGatewayFee(data: (fee, success:success)))
                    }
                }
            }
        }
    }

   class func verifyAddress(_ assetName: String, address: String, callback:@escaping (Bool) -> Void) {
        async {
            let data = try? await(GraphQLManager.shared.verifyAddress(assetName: assetName, address: address))
            main {
                if case let data?? = data {
                    callback(data.valid)
                } else {
                    callback(false)
                }
            }
        }
    }

    func getObjects(assetId: String, amount: String, address: String, feeId: String, feeAmount: String, isEOS: Bool, callback:@escaping (Any) -> Void) {
        getChainId { (id) in
            if let memoKey = self.state.memoKey.value {
                let name = appData.assetInfo[assetId]?.symbol.filterJade

                let memo = self.state.memo.value
                let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                    if let infos = infos as? (block_id: String, block_num: String) {
                        if var amount = amount.toDouble() {
                            let value = pow(10, (appData.assetInfo[assetId]?.precision)!)
                            amount = amount * Double(truncating: value as NSNumber)
                            let feeAmout = feeAmount.toDouble()! * Double(truncating: pow(10, (appData.assetInfo[feeId]?.precision)!) as NSNumber)
                            let jsonstr = BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                              block_id: infos.block_id,
                                                                              expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                              chain_id: id,
                                                                              from_user_id: Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                                              to_user_id: Int32(getUserId((self.state.data.value?.gatewayAccount)!)),
                                                                              asset_id: Int32(getUserId(assetId)),
                                                                              receive_asset_id: Int32(getUserId(assetId)),
                                                                              amount: Int64(amount),
                                                                              fee_id: Int32(getUserId(feeId)),
                                                                              fee_amount: Int64(feeAmout),
                                                                              memo: isEOS ? GraphQLManager.shared.memo(name!, address: address + "[\(memo)]") :
                                                                                GraphQLManager.shared.memo(name!, address: address),
                                                                              from_memo_key: UserManager.shared.account.value?.memoKey,
                                                                              to_memo_key: memoKey)
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
    }

    func getFinalAmount(feeId: String, amount: Decimal, available: Double) -> (Decimal, String) {

        let allAmount = Decimal(available)
        var requestAmount: String = ""

        var finalAmount: Decimal = amount
        if feeId != AssetConfiguration.CYB {
            if let gatewayFeeAmount = self.state.gatewayFee.value?.0, let gatewayFee = Decimal(string: gatewayFeeAmount.amount) {
                if allAmount < gatewayFee + amount {
                    finalAmount -= gatewayFee
                    requestAmount = (amount - gatewayFee).stringValue
                } else {
                    requestAmount = amount.stringValue
                }
            }
        } else {
            requestAmount = amount.stringValue
        }
        if let data = self.state.data.value {
            finalAmount -= Decimal(data.fee)
        }
        return (finalAmount, requestAmount)
    }

    func chooseOrAddAddress(_ sender: String) {
        if AddressManager.shared.getWithDrawAddressListWith(sender).count == 0 {
            self.openAddAddress(sender)
        } else {
            showPicker(sender)
        }
    }
}
