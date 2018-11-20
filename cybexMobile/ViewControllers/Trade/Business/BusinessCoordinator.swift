//
//  BusinessCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import cybex_ios_core_cpp

protocol BusinessCoordinatorProtocol {
    func parentIsLoading(_ vc: UIViewController?) -> Bool
    func parentStartLoading(_ vc: UIViewController?)
    func parentEndLoading(_ vc: UIViewController?)
}

protocol BusinessStateManagerProtocol {
    var state: BusinessState { get }

    func switchPrice(_ price: String)
    func adjustPrice(_ plus: Bool, pricePricision: Int)

    func changeAmountAction(_ amount: String)

    func changePercent(_ percent: Double, isBuy: Bool, assetID: String, pricision: Int)
    func getBalance(_ assetID: String)

    func getFee(_ focusAssetId: String)
    func resetState()

    func postLimitOrder(_ pair: Pair, isBuy: Bool, callback: @escaping (_ success: Bool) -> Void)
    func checkBalance(_ pair: Pair, isBuy: Bool) -> Bool?
}

class BusinessCoordinator: NavCoordinator {
    var store = Store<BusinessState>(
        reducer: businessReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension BusinessCoordinator: BusinessCoordinatorProtocol {
    func parentIsLoading(_ vc: UIViewController?) -> Bool {
        if let vc = vc as? BaseViewController {
            return vc.isLoading()
        }

        return false
    }

    func parentStartLoading(_ vc: UIViewController?) {
        if !parentIsLoading(vc) {
            if let vc = vc as? BaseViewController {
                vc.startLoading()
            }
        }

    }

    func parentEndLoading(_ vc: UIViewController?) {
        if let vc = vc as? BaseViewController {
            vc.endLoading()
        }
    }
}

extension BusinessCoordinator: BusinessStateManagerProtocol {
    var state: BusinessState {
        return store.state
    }

    func changeAmountAction(_ amount: String) {
        self.store.dispatch(ChangeAmountAction(amount: amount))
    }

    func switchPrice(_ price: String) {
        self.store.dispatch(ChangePriceAction(price: price))
    }

    func adjustPrice(_ plus: Bool, pricePricision: Int) {
        self.store.dispatch(AdjustPriceAction(plus: plus, pricision: pricePricision))
    }

    func getFee(_ focusAssetId: String) {
        if let str = BitShareCoordinator.getLimitOrderOperation(0, expiration: 0, asset_id: 0, amount: 0, receive_asset_id: 0, receive_amount: 0, fee_id: 0, fee_amount: 0) {
            calculateFee(str, focusAssetId: focusAssetId) { (success, amount, assetID) in
                self.store.dispatch(FeeFetchedAction(success: success, amount: amount, assetID: assetID))
            }
        }
    }

    func changePercent(_ percent: Double, isBuy: Bool, assetID: String, pricision: Int) {
        let feeAmount = self.state.property.feeAmount.value
        let balance = self.state.property.balance.value
        let feeId = self.state.property.feeID.value

        if let price = self.state.property.price.value.toDouble(), price != 0, feeAmount != 0, balance != 0 {
            var amount: Decimal = Decimal(floatLiteral: 0)

            let priceDecimal = self.state.property.price.value.toDecimal()!
            let percentDecimal = Decimal(floatLiteral: percent)

            if isBuy {
                if feeId == assetID {
                    amount = (balance - feeAmount) * percentDecimal / priceDecimal
                } else {
                    amount = balance * percentDecimal / priceDecimal
                }
            } else {
                if feeId == assetID {
                    amount = (balance - feeAmount) * percentDecimal
                    log.debug("amount ----- \(amount.doubleValue)")
                } else {
                    amount = balance * percentDecimal
                }
            }

            if amount > Decimal(floatLiteral: 0) {
                self.store.dispatch(SwitchPercentAction(amount: amount, pricision: pricision))
            }

        }
    }

    func getBalance(_ assetID: String) {
        if let balances = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
            return balance.assetType.filterJade == assetID
        }).first {
            let amount = getRealAmount(balances.assetType, amount: balances.balance)
            self.store.dispatch(BalanceFetchedAction(amount: amount))
        }
    }

    func resetState() {
        self.store.dispatch(ResetTrade())
    }

    func postLimitOrder(_ pair: Pair, isBuy: Bool, callback: @escaping (_ success: Bool) -> Void) {
        guard let baseInfo = appData.assetInfo[pair.base],
            let quoteInfo = appData.assetInfo[pair.quote],
            let feeInfo = appData.assetInfo[self.state.property.feeID.value],
            let userid = UserManager.shared.account.value?.id,
            self.state.property.feeAmount.value != 0,
            let curAmount = self.state.property.amount.value.toDouble(), curAmount != 0,
            let price = self.state.property.price.value.toDouble(), price != 0 else { return }
        guard  let curAmountDecimal = self.state.property.amount.value.toDecimal(),
            curAmountDecimal != 0,
            let priceDecimal = self.state.property.price.value.toDecimal(),
            priceDecimal != 0 else { return }

        let total = curAmountDecimal * priceDecimal

        //    let total = price * cur_amount
        let assetID = isBuy ? baseInfo.id : quoteInfo.id

        let amount = isBuy ?
            Int64((total * pow(10, baseInfo.precision)).string(digits: 0, roundingMode: .down)) :
            Int64((curAmountDecimal * pow(10, quoteInfo.precision)).string(digits: 0, roundingMode: .down))

        let receiveAssetID = isBuy ? quoteInfo.id : baseInfo.id
        let receiveAmount = isBuy ?
            Int64((curAmountDecimal * pow(10, quoteInfo.precision)).string(digits: 0, roundingMode: .down)) :
            Int64((total * pow(10, baseInfo.precision)).string(digits: 0, roundingMode: .down))

        let feeAmount = Int64(round(self.state.property.feeAmount.value.doubleValue * pow(10, feeInfo.precision.double)))

        blockchainParams { (blockchainParams) in
            if let jsonStr = BitShareCoordinator.getLimitOrder(blockchainParams.block_num,
                                                               block_id: blockchainParams.block_id,
                                                               expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                               chain_id: blockchainParams.chain_id,
                                                               user_id: userid.getID,
                                                               order_expiration: Date().timeIntervalSince1970 + 3600 * 24 * 365,
                                                               asset_id: assetID.getID,
                                                               amount: amount!,
                                                               receive_asset_id: receiveAssetID.getID,
                                                               receive_amount: receiveAmount!,
                                                               fee_id: self.state.property.feeID.value.getID,
                                                               fee_amount: feeAmount) {

                let request = BroadcastTransactionRequest(response: { (data) in
                    if String(describing: data) == "<null>" {
                        callback(true)
                    } else {
                        callback(false)
                    }
                }, jsonstr: jsonStr)

                CybexWebSocketService.shared.send(request: request)
            }

        }
    }

    func checkBalance(_ pair: Pair, isBuy: Bool) -> Bool? {
        guard let baseInfo = appData.assetInfo[pair.base],
            let quoteInfo = appData.assetInfo[pair.quote],
            self.state.property.feeAmount.value != 0,
            let curAmount = self.state.property.amount.value.toDouble(), curAmount != 0,
            let price = self.state.property.price.value.toDouble(), price != 0 else { return nil }

        var total: Decimal = Decimal(floatLiteral: 0)
        let priceDecimal = self.state.property.price.value.toDecimal()!
        let amountDecimal = self.state.property.amount.value.toDecimal()!

        if isBuy {
            if self.state.property.feeID.value == baseInfo.id {
                total = priceDecimal * amountDecimal + self.state.property.feeAmount.value
            } else {
                total = priceDecimal * amountDecimal
            }
        } else {
            if self.state.property.feeID.value == quoteInfo.id {
                total = amountDecimal + self.state.property.feeAmount.value
            } else {
                total = amountDecimal
            }

        }
        let balanceDouble = self.state.property.balance.value.doubleValue
        let totalDouble = total.doubleValue

        if balanceDouble >= totalDouble {
            return true
        }
        return false
    }
}
