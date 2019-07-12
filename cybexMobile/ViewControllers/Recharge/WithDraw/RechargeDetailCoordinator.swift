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
    func openWithdrawRecodeList(_ assetName: String)
    func openAddAddressWithAddress(_ withdrawAddress: WithdrawAddress)
}

protocol RechargeDetailStateManagerProtocol {
    var state: RechargeDetailState { get }

    func fetchWithDrawInfoData(_ assetName: String)
    static func verifyAddress(_ assetName: String, address: String, callback:@escaping (Bool) -> Void)
    func getFee(_ assetId: String, address: String, tag: Bool)
    func withDraw(assetId: String,
                    amount: String,
                    address: String,
                    feeId: String,
                    feeAmount: String,
                    tag: Bool,
                    callback:@escaping (Any) -> Void)
    func getFinalAmount(feeId: String, amount: Decimal, available: Decimal) -> (Decimal, String)

    func chooseOrAddAddress(_ sender: WithdrawAddress)
    func fetchDepositWriteInfo(_ assetId: String)
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

    func openWithdrawRecodeList(_ assetName: String) {
        if let vc = R.storyboard.recode.rechargeRecodeViewController() {
            vc.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
            vc.recordType = .WITHDRAW
            vc.assetName = assetName
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func showPicker(_ asset: String) {
        let width = ModalSize.full
        let height = ModalSize.custom(size: 244)
        let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let presenter = Presentr(presentationType: customType)
        presenter.keyboardTranslationType = .moveUp

        let items = AddressManager.shared.getWithDrawAddressListWith(asset)
        var context = PickerContext()
        context.items = items.map({ $0.name }) as AnyObject
        context.pickerDidSelected = { [weak self] (picker: UIPickerView) -> Void in
            guard let self = self else { return }
            let selectedIndex =  picker.selectedRow(inComponent: 0)
            self.store.dispatch(SelectedAddressAction(data: items[selectedIndex]))
        }

        presentVC(PickerCoordinator.self, animated: true, context: context, navSetup: nil) { (top, target) in
            top.customPresentViewController(presenter, viewController: target, animated: true)
        }
    }

    func openAddAddress(_ withdrawAddress: WithdrawAddress) {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            vc.addressType = .withdraw
            vc.withdrawAddress = withdrawAddress
            vc.asset = withdrawAddress.currency
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
  
}
extension RechargeDetailCoordinator: RechargeDetailStateManagerProtocol {
    var state: RechargeDetailState {
        return store.state
    }

    func fetchWithDrawInfoData(_ assetName: String) {
        guard let setting = AppConfiguration.shared.enableSetting.value else {
            return
        }

        let gateway2 = setting.gateWay2
        if gateway2 {
            Gateway2Service.request(target: .asset(name: assetName), success: { (json) in
                if let model = GatewayAssetResponseModel.deserialize(from: json.dictionaryObject) {
                    GatewayService.Config.gateway2ID = model.withdrawPrefix
                    let info = WithdrawinfoObject(minValue: model.minWithdraw.double()!, fee: model.withdrawFee.double()!, type: "", asset: "", gatewayAccount: model.gatewayAccount, precision: model.precision.int!)
                    
                    self.getWithdrawAccountInfo(info.gatewayAccount)
                    self.store.dispatch(FetchWithdrawInfo(data: info))
                }
            }, error: { (_) in

            }) { (_) in
                
            }
            return
        }

        GatewayService().getWithdrawInfo(assetName: assetName).done { (data) in
            if case let data? = data {
                self.getWithdrawAccountInfo(data.gatewayAccount)
                self.store.dispatch(FetchWithdrawInfo(data: data))
            }
        }.cauterize()
    }

    func getWithdrawAccountInfo(_ userID: String) {
        let requeset = GetFullAccountsRequest(name: userID) { (response) in
            if let data = response as? FullAccount, let account = data.account {
                self.store.dispatch(FetchWithdrawMemokey(memoKey: account.memoKey, gatewayUid: account.id))
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }

    func getFee(_ assetId: String, address: String, tag: Bool) {
        let name = appData.assetInfo[assetId]?.symbol.filterSystemPrefix
        let memo = self.state.memo.value

        var memoAddress = GatewayService.withDrawMemo(name!, address: address)
        if tag {
            if !memo.isEmpty {
                memoAddress = GatewayService.withDrawMemo(name!, address: address + "[\(memo)]")
            }
        }

        let operationString = BitShareCoordinator.getTransterOperation(0,
                                                                          to_user_id: 0,
                                                                          asset_id: 0,
                                                                          amount: 0,
                                                                          fee_id: 0,
                                                                          fee_amount: 0,
                                                                          memo: memoAddress,
                                                                          from_memo_key: "",
                                                                          to_memo_key: "")

        CybexChainHelper.calculateFee(operationString, operationID: OperationId.transfer, focusAssetId: assetId) { (success, amount, feeId) in
            let dictionary = ["asset_id": feeId, "amount": amount.stringValue]
            guard let fee = Fee.deserialize(from: dictionary) else { return }
            self.store.dispatch(FetchCybexFee(data: (fee, success:success)))
        }
    }

   class func verifyAddress(_ assetName: String, address: String, callback:@escaping (Bool) -> Void) {
        guard let setting = AppConfiguration.shared.enableSetting.value else {
            return
        }

        let gateway2 = setting.gateWay2
        if gateway2 {
            Gateway2Service.request(target: .validateAddress(assetName: assetName, address: address), success: { (json) in
                callback(json["valid"].boolValue)
            }, error: { (_) in
                callback(false)
            }) { (_) in
                callback(false)
            }
            return
        }
        GatewayService().verifyAddress(assetName: assetName, address: address).done { (data) in
            if case let data? = data {
                callback(data.valid)
            } else {
                callback(false)
            }
        }.cauterize()
    }

    func withDraw(assetId: String, amount: String, address: String, feeId: String, feeAmount: String, tag: Bool, callback: @escaping (Any) -> Void) {
        if let memoKey = self.state.memoKey.value {
            let name = appData.assetInfo[assetId]?.symbol.filterSystemPrefix
            let memo = self.state.memo.value
            var memoAddress = GatewayService.withDrawMemo(name!, address: address)
            if tag {
                if !memo.isEmpty {
                    memoAddress = GatewayService.withDrawMemo(name!, address: address + "[\(memo)]")
                }
            }

            CybexChainHelper.blockchainParams { (blockInfo) in
                let value = pow(10, (appData.assetInfo[assetId]?.precision)!)

                let amount = amount.decimal() * value
                let feeAmout = feeAmount.decimal() * pow(10, (appData.assetInfo[feeId]?.precision)!)
                guard let fromMemoKey = UserManager.shared.getCachedAccount()?.memoKey, !fromMemoKey.isEmpty,
                let uid = UserManager.shared.getCachedAccount()?.id else { return }
                let jsonstr = BitShareCoordinator.getTransaction(blockInfo.block_num.int32,
                                                                 block_id: blockInfo.block_id,
                                                                 expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration,
                                                                 chain_id: CybexConfiguration.shared.chainID.value,
                                                                 from_user_id: uid.getSuffixID,
                                                                 to_user_id: self.state.gatewayUid.value!.getSuffixID,
                                                                 asset_id: assetId.getSuffixID,
                                                                 receive_asset_id: assetId.getSuffixID,
                                                                 amount: amount.int64Value,
                                                                 fee_id: feeId.getSuffixID,
                                                                 fee_amount: feeAmout.int64Value,
                                                                 memo: memoAddress,
                                                                 from_memo_key: fromMemoKey,
                                                                 to_memo_key: memoKey)
                let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                    callback(data)
                }, jsonstr: jsonstr)
                CybexWebSocketService.shared.send(request: withdrawRequest)
            }
        }

    }

    func getFinalAmount(feeId: String, amount: Decimal, available: Decimal) -> (Decimal, String) {
        let allAmount = available
        var requestAmount: String = ""

        var finalAmount: Decimal = amount
        if feeId != AssetConfiguration.CybexAsset.CYB.id {
            if let gatewayFeeAmount = self.state.fee.value?.0, let gatewayFee = Decimal(string: gatewayFeeAmount.amount) {
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

    func chooseOrAddAddress(_ sender: WithdrawAddress) {
        if AddressManager.shared.getWithDrawAddressListWith(sender.currency).count == 0 {
            self.openAddAddress(sender)
        } else {
            showPicker(sender.currency)
        }
    }
    
    func fetchDepositWriteInfo(_ assetId: String) {
        AppService.request(target: AppAPI.withdrawAnnounce(assetId: assetId), success: { (json) in
            if let data = RechargeWorldInfo.deserialize(from: json.dictionaryObject) {
                self.store.dispatch(FetchWithdrawWordInfo(data: data))
            }
            else {
                self.state.withdrawMsgInfo.accept(nil)
            }
        }, error: { (_) in

        }) { (_) in

        }
    }
}
