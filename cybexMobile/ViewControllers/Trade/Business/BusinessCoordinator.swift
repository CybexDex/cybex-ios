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
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<BusinessState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    func switchPrice(_ price: String)
    func adjustPrice(_ plus: Bool, price_pricision: Int)

    func changeAmountAction(_ amount: String)

    func changePercent(_ percent: Double, isBuy: Bool, assetID: String, pricision: Int)
    func getBalance(_ assetID: String)

    func getFee(_ focus_asset_id: String)
    func resetState()

    func postLimitOrder(_ pair: Pair, isBuy: Bool, callback: @escaping (_ success: Bool) -> Void)
    func checkBalance(_ pair: Pair, isBuy: Bool) -> Bool?
}

class BusinessCoordinator: AccountRootCoordinator {

    lazy var creator = BusinessPropertyActionCreate()

    var store = Store<BusinessState>(
        reducer: BusinessReducer,
        state: nil,
        middleware: [TrackingMiddleware]
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

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<BusinessState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

    func changeAmountAction(_ amount: String) {
        self.store.dispatch(ChangeAmountAction(amount: amount))
    }

    func switchPrice(_ price: String) {
        self.store.dispatch(changePriceAction(price: price))
    }

    func adjustPrice(_ plus: Bool, price_pricision: Int) {
        self.store.dispatch(adjustPriceAction(plus: plus, pricision: price_pricision))
    }

    func getFee(_ focus_asset_id: String) {
        if let str = BitShareCoordinator.getLimitOrderOperation(0, expiration: 0, asset_id: 0, amount: 0, receive_asset_id: 0, receive_amount: 0, fee_id: 0, fee_amount: 0) {
            calculateFee(str, focus_asset_id: focus_asset_id) { (success, amount, assetID) in
                self.store.dispatch(feeFetchedAction(success: success, amount: amount, assetID: assetID))
            }
        }
    }

    func changePercent(_ percent: Double, isBuy: Bool, assetID: String, pricision: Int) {
        let fee_amount = self.state.property.fee_amount.value
        let balance = self.state.property.balance.value
        let fee_id = self.state.property.feeID.value

        if let price = self.state.property.price.value.toDouble(), price != 0, fee_amount != 0, balance != 0 {
            var amount: Decimal = Decimal(floatLiteral: 0)

            let priceDecimal = self.state.property.price.value.toDecimal()!
            let percentDecimal = Decimal(floatLiteral: percent)

            if isBuy {
                if fee_id == assetID {
                    amount = (balance - fee_amount) * percentDecimal / priceDecimal
                } else {
                    amount = balance * percentDecimal / priceDecimal
                }
            } else {
                if fee_id == assetID {
                    amount = (balance - fee_amount) * percentDecimal
                    log.debug("amount ----- \(amount.doubleValue)")
                } else {
                    amount = balance * percentDecimal
                }
            }

            if amount > Decimal(floatLiteral: 0) {
                self.store.dispatch(switchPercentAction(amount: amount, pricision: pricision))
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
        self.store.dispatch(resetTrade())
    }

    func postLimitOrder(_ pair: Pair, isBuy: Bool, callback: @escaping (_ success: Bool) -> Void) {
        guard let base_info = appData.assetInfo[pair.base], let quote_info = appData.assetInfo[pair.quote], let fee_info = appData.assetInfo[self.state.property.feeID.value], let userid = UserManager.shared.account.value?.id, self.state.property.fee_amount.value != 0, let cur_amount = self.state.property.amount.value.toDouble(), cur_amount != 0, let price = self.state.property.price.value.toDouble(), price != 0 else { return }
        guard  let cur_amount_Decimal = self.state.property.amount.value.toDecimal(), cur_amount_Decimal != 0, let price_Decimal = self.state.property.price.value.toDecimal(), price_Decimal != 0 else { return }

        let total = cur_amount_Decimal * price_Decimal
        //    let total = price * cur_amount
        let assetID = isBuy ? base_info.id : quote_info.id

        let amount = isBuy ? Int64((total * pow(10, base_info.precision)).string(digits: 0, roundingMode: .down)) : Int64((cur_amount_Decimal * pow(10, quote_info.precision)).string(digits: 0, roundingMode: .down))
        //    let amount = isBuy ? Int32(round(total * pow(10, base_info.precision.double))) : Int32(round(cur_amount * pow(10, quote_info.precision.double)))

        let receive_assetID = isBuy ? quote_info.id : base_info.id
        let receive_amount = isBuy ? Int64((cur_amount_Decimal * pow(10, quote_info.precision)).string(digits: 0, roundingMode: .down)) : Int64((total * pow(10, base_info.precision)).string(digits: 0, roundingMode: .down))
        //    let receive_amount = isBuy ? Int32(round(cur_amount * pow(10, quote_info.precision.double))) : Int32(round(total * pow(10, base_info.precision.double)))

        let fee_amount = Int64(round(self.state.property.fee_amount.value.doubleValue * pow(10, fee_info.precision.double)))

        blockchainParams { (blockchain_params) in
            if let jsonStr = BitShareCoordinator.getLimitOrder(blockchain_params.block_num, block_id: blockchain_params.block_id, expiration: Date().timeIntervalSince1970 + 10 * 3600, chain_id: blockchain_params.chain_id, user_id: userid.getID, order_expiration: Date().timeIntervalSince1970 + 3600 * 24 * 365, asset_id: assetID.getID, amount: amount!, receive_asset_id: receive_assetID.getID, receive_amount: receive_amount!, fee_id: self.state.property.feeID.value.getID, fee_amount: fee_amount) {

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
        guard let base_info = appData.assetInfo[pair.base], let quote_info = appData.assetInfo[pair.quote], self.state.property.fee_amount.value != 0, let cur_amount = self.state.property.amount.value.toDouble(), cur_amount != 0, let price = self.state.property.price.value.toDouble(), price != 0 else { return nil }

        var total: Decimal = Decimal(floatLiteral: 0)
        let priceDecimal = self.state.property.price.value.toDecimal()!
        let amountDecimal = self.state.property.amount.value.toDecimal()!

        if isBuy {
            if self.state.property.feeID.value == base_info.id {
                total = priceDecimal * amountDecimal + self.state.property.fee_amount.value
            } else {
                total = priceDecimal * amountDecimal
            }
        } else {
            if self.state.property.feeID.value == quote_info.id {
                total = amountDecimal + self.state.property.fee_amount.value
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
