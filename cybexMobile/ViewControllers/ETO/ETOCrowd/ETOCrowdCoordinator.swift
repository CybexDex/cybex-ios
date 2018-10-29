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
    func showConfirm(_ transferAmount: Double)
    func reOpenCrowd()
}

protocol ETOCrowdStateManagerProtocol {
    var state: ETOCrowdState { get }

    func switchPageState(_ state: PageState)

    func fetchData()
    func fetchUserRecord()
    func fetchFee()

    func unsetValidStatus()
    func checkValidStatus(_ transferAmount: Double)

    func joinCrowd(_ transferAmount: Double, callback: @escaping CommonAnyCallback)
}

class ETOCrowdCoordinator: ETORootCoordinator {
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
    func showConfirm(_ transferAmount: Double) {
        guard let data = self.state.data.value,
            let fee = self.state.fee.value,
            let feeInfo = appData.assetInfo[fee.assetId],
            let feeAmount = fee.amount.toDouble()?.string(digits: feeInfo.precision, roundingMode: .down) else { return }

        self.rootVC.topViewController?.showConfirm(R.string.localizable.eto_submit_confirm.key.localized(),
                                                   attributes: confirmSubmitCrowd(data.name, amount: "\(transferAmount) \(data.baseTokenName)",
                                                    fee: "\(feeAmount) \(feeInfo.symbol.filterJade)"), setup: { (_) in
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
            if value.symbol.filterJade == data.baseTokenName {
                assetID = value.id
                break
            }
        }

        guard !assetID.isEmpty,
            let operation = BitShareCoordinator.getTransterOperation(0,
                                                                     to_user_id: 0,
                                                                     asset_id: Int32(getUserId(assetID)),
                                                                     amount: 0,
                                                                     fee_id: 0,
                                                                     fee_amount: 0,
                                                                     memo: "",
                                                                     from_memo_key: "",
                                                                     to_memo_key: "") else { return }

        calculateFee(operation, focusAssetId: assetID, operationID: .transfer) { (success, amount, feeId) in
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

    func checkValidStatus(_ transferAmount: Double) {
        guard self.state.validStatus.value == .notValid else { return }

        guard let balances = UserManager.shared.balances.value, let data = self.state.data.value, let userModel = self.state.userData.value else { return }

        let balance = balances.filter { (balance) -> Bool in
            if let name = appData.assetInfo[balance.assetType]?.symbol.filterJade {
                return name == data.baseTokenName
            }

            return false
        }.first

        if let balance = balance, let info = appData.assetInfo[balance.assetType] {
            let amount = getRealAmount(balance.assetType, amount: balance.balance).string(digits: info.precision, roundingMode: .down)

            if transferAmount > amount.toDouble()! {
                self.store.dispatch(ChangeETOValidStatusAction(status: .notEnough))
                return
            }
        } else {
            self.store.dispatch(ChangeETOValidStatusAction(status: .notEnough))
            return
        }

        if transferAmount > data.baseMaxQuota {
            self.store.dispatch(ChangeETOValidStatusAction(status: .moreThanLimit))
            return
        }

        let remain = data.baseMaxQuota - userModel.currentBaseTokenCount

        if transferAmount > remain {
            self.store.dispatch(ChangeETOValidStatusAction(status: .notAvaliableLimit))
            return
        }

        if transferAmount < data.baseMinQuota {
            self.store.dispatch(ChangeETOValidStatusAction(status: .lessThanLeastLimit))
            return
        }

        let unit = 1 / pow(10, data.baseAccuracy)

        let multiple = Decimal(floatLiteral: transferAmount) / unit
        let mantissa = Decimal(floatLiteral: floor(multiple.doubleValue))

        if (multiple - mantissa) > Decimal(floatLiteral: 0) {
            self.store.dispatch(ChangeETOValidStatusAction(status: .precisionError))
            return
        }
        self.store.dispatch(ChangeETOValidStatusAction(status: .ok))
    }

    func joinCrowd(_ transferAmount: Double, callback: @escaping CommonAnyCallback) {
        guard let fee = self.state.fee.value, let data = self.state.data.value else { return }

        var assetID = ""
        for (_, value) in appData.assetInfo {
            if value.symbol.filterJade == data.baseTokenName {
                assetID = value.id
                break
            }
        }

        guard !assetID.isEmpty,
            let uid = UserManager.shared.account.value?.id,
            let info = appData.assetInfo[assetID],
            let feeAmount = fee.amount.toDouble(),
            let feeInfo = appData.assetInfo[fee.assetId] else { return }
        let value = pow(10, info.precision)
        let amount = transferAmount * Double(truncating: value as NSNumber)

        let feeAmout = feeAmount * Double(truncating: pow(10, feeInfo.precision) as NSNumber)

        getChainId { (id) in
            let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                if let infos = infos as? (block_id: String, block_num: String) {
                    let accountRequeset = GetFullAccountsRequest(name: data.receiveAddress) { (response) in
                        if let response = response as? FullAccount, let account = response.account {
                            let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                              block_id: infos.block_id,
                                                                              expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                              chain_id: id,
                                                                              from_user_id: Int32(getUserId(uid)),
                                                                              to_user_id: Int32(getUserId(account.id)),
                                                                              asset_id: Int32(getUserId(assetID)),
                                                                              receive_asset_id: Int32(getUserId(assetID)),
                                                                              amount: Int64(amount),
                                                                              fee_id: Int32(getUserId(fee.assetId)),
                                                                              fee_amount: Int64(feeAmout),
                                                                              memo: "",
                                                                              from_memo_key: "",
                                                                              to_memo_key: "")
                            guard let ope = jsonstr else {
                                main {
                                    callback("")
                                }
                                return
                            }
                            let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                                main {
                                    callback(data)
                                }
                            }, jsonstr: ope)
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
            CybexWebSocketService.shared.send(request: requeset)
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

        }, error: { (error) in

        }) { (_) in

        }
    }

    func switchPageState(_ state: PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
