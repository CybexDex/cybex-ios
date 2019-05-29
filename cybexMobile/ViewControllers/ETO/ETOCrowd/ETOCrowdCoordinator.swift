//
//  ETOCrowdCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import cybex_ios_core_cpp

protocol ETOCrowdCoordinatorProtocol {
    func showConfirm(_ transferAmount: Decimal)
    func reOpenCrowd()
}

protocol ETOCrowdStateManagerProtocol {
    var state: ETOCrowdState { get }

    func switchPageState(_ state: PageState)

    func fetchData()
    func fetchUserRecord()
    func fetchFee()

    func unsetValidStatus()
    func checkValidStatus(_ transferAmount: Decimal)

    func joinCrowd(_ transferAmount: Decimal, callback: @escaping CommonAnyCallback)
}

class ETOCrowdCoordinator: NavCoordinator {
    var store = Store(
        reducer: ETOCrowdReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ETOCrowdState {
        return store.state
    }

    override func register() {
        Broadcaster.register(ETOCrowdCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOCrowdStateManagerProtocol.self, observer: self)
    }
}

extension ETOCrowdCoordinator: ETOCrowdCoordinatorProtocol {
    func showConfirm(_ transferAmount: Decimal) {
        guard let data = self.state.data.value,
            let fee = self.state.fee.value,
            let feeInfo = appData.assetInfo[fee.assetId]
             else { return }

        let feeAmount = fee.amount.formatCurrency(digitNum: feeInfo.precision)
        self.rootVC.topViewController?.showConfirm(R.string.localizable.eto_submit_confirm.key.localized(),
                                                   attributes: UIHelper.confirmSubmitCrowd(data.name, amount: "\(transferAmount) \(data.baseTokenName)",
                                                    fee: "\(feeAmount) \(feeInfo.symbol.filterSystemPrefix)"), setup: { (_) in
                //            for label in labels {
                //                label.content.numberOfLines = 1
                //                label.content.lineBreakMode = .byTruncatingMiddle
                //            }
            })
    }

    func reOpenCrowd() {
        if let vc = R.storyboard.etO.etoCrowdViewController() {
            vc.coordinator = ETOCrowdCoordinator(rootVC: self.rootVC)
            self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] = vc
        }
    }
}

extension ETOCrowdCoordinator: ETOCrowdStateManagerProtocol {
    func fetchFee() {
        guard let data = self.state.data.value else { return }

        var assetID = ""
        for (_, value) in appData.assetInfo {
            if value.symbol.filterSystemPrefix == data.baseTokenName {
                assetID = value.id
                break
            }
        }

        guard !assetID.isEmpty else { return }

        let operation = BitShareCoordinator.getTransterOperation(0,
                                                                 to_user_id: 0,
                                                                 asset_id: assetID.getSuffixID,
                                                                 amount: 0,
                                                                 fee_id: 0,
                                                                 fee_amount: 0,
                                                                 memo: "",
                                                                 from_memo_key: "",
                                                                 to_memo_key: "")
        
        CybexChainHelper.calculateFee(operation, operationID: OperationId.transfer, focusAssetId: assetID) { (success, amount, feeId) in
            let dictionary = ["asset_id": feeId, "amount": amount.stringValue]

            if success {
                guard let fee = Fee.deserialize(from: dictionary) else { return }
                self.store.dispatch(SetFeeAction(fee: fee))
            } else {
                self.store.dispatch(ChangeETOValidStatusAction(status: .feeNotEnough))
            }

        }
    }

    func unsetValidStatus() {
        guard self.state.validStatus.value != .feeNotEnough else { return }

        self.store.dispatch(ChangeETOValidStatusAction(status: .notValid))
    }

    func checkValidStatus(_ transferAmount: Decimal) {
        guard self.state.validStatus.value == .notValid else { return }

        guard let balances = UserManager.shared.fullAccount.value?.balances, let data = self.state.data.value, let userModel = self.state.userData.value else { return }

        let balance = balances.filter { (balance) -> Bool in
            if let name = appData.assetInfo[balance.assetType]?.symbol.filterSystemPrefix {
                return name == data.baseTokenName
            }

            return false
        }.first

        if let balance = balance, let _ = appData.assetInfo[balance.assetType] {
            let amount = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance)

            if transferAmount > amount {
                self.store.dispatch(ChangeETOValidStatusAction(status: .notEnough))
                return
            }
        } else {
            self.store.dispatch(ChangeETOValidStatusAction(status: .notEnough))
            return
        }

        if transferAmount > data.baseMaxQuota.decimal {
            self.store.dispatch(ChangeETOValidStatusAction(status: .moreThanLimit))
            return
        }

        let remain = data.baseMaxQuota - userModel.currentBaseTokenCount

        if transferAmount > remain.decimal {
            self.store.dispatch(ChangeETOValidStatusAction(status: .notAvaliableLimit))
            return
        }

        if transferAmount < data.baseMinQuota.decimal {
            self.store.dispatch(ChangeETOValidStatusAction(status: .lessThanLeastLimit))
            return
        }

        let unit:Decimal = 1 / pow(10, data.baseAccuracy)

        let multiple = transferAmount / unit
        let mantissa = multiple.floor

        if (multiple - mantissa) > 0 {
            self.store.dispatch(ChangeETOValidStatusAction(status: .precisionError))
            return
        }
        self.store.dispatch(ChangeETOValidStatusAction(status: .ok))
    }

    func joinCrowd(_ transferAmount: Decimal, callback: @escaping CommonAnyCallback) {
        guard let fee = self.state.fee.value, let data = self.state.data.value else { return }

        var assetID = ""
        for (_, value) in appData.assetInfo {
            if value.symbol.filterSystemPrefix == data.baseTokenName {
                assetID = value.id
                break
            }
        }

        guard !assetID.isEmpty,
            let uid = UserManager.shared.getCachedAccount()?.id,
            let info = appData.assetInfo[assetID],
            let feeInfo = appData.assetInfo[fee.assetId] else { return }
        let value = pow(10, info.precision)
        let amount = transferAmount * value

        let feeAmout = fee.amount.decimal() * pow(10, feeInfo.precision)

        CybexChainHelper.blockchainParams { (blockInfo) in
            let accountRequeset = GetFullAccountsRequest(name: data.receiveAddress) { (response) in
                if let response = response as? FullAccount, let account = response.account {
                    let jsonstr =  BitShareCoordinator.getTransaction(blockInfo.block_num.int32,
                                                                      block_id: blockInfo.block_id,
                                                                      expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration,
                                                                      chain_id: CybexConfiguration.shared.chainID.value,
                                                                      from_user_id: uid.getSuffixID,
                                                                      to_user_id: account.id.getSuffixID,
                                                                      asset_id: assetID.getSuffixID,
                                                                      receive_asset_id: assetID.getSuffixID,
                                                                      amount: amount.int64Value,
                                                                      fee_id: fee.assetId.getSuffixID,
                                                                      fee_amount: feeAmout.int64Value,
                                                                      memo: "",
                                                                      from_memo_key: "",
                                                                      to_memo_key: "")

                    let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                        main {
                            callback(data)
                        }
                    }, jsonstr: jsonstr)
                    CybexWebSocketService.shared.send(request: withdrawRequest)
                } else {
                    main {
                        callback("")
                    }
                }
            }
            CybexWebSocketService.shared.send(request: accountRequeset)
        }

    }

    func fetchData() {
        Broadcaster.notify(ETODetailStateManagerProtocol.self) {(coor) in
            if let model = coor.state.data.value?.projectModel {
                self.store.dispatch(SetProjectDetailAction(data: model))
            }
        }
    }

    func fetchUserRecord() {
        guard let name = UserManager.shared.name.value, let data = self.state.data.value else { return }

        ETOMGService.request(target: .refreshUserState(name: name, pid: data.id), success: { (json) in
            if let model = ETOUserModel.deserialize(from: json.dictionaryObject) {
                self.store.dispatch(FetchCurrentTokenCountAction(userModel: model))
            }

        }, error: { (_) in

        }) { (_) in

        }
    }

    func switchPageState(_ state: PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
