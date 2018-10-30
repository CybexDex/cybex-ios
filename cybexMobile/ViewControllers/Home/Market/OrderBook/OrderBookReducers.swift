//
//  OrderBookReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func orderBookReducer(action: Action, state: OrderBookState?) -> OrderBookState {
    return OrderBookState(isLoading: loadingReducer(state?.isLoading, action: action),
                          page: pageReducer(state?.page, action: action),
                          errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                          property: orderBookPropertyReducer(state?.property, action: action))
}

func orderBookPropertyReducer(_ state: OrderBookPropertyState?, action: Action) -> OrderBookPropertyState {
    let state = state ?? OrderBookPropertyState()

    switch action {
    case let action as FetchedLimitData:
        state.pair.accept(action.pair)
        let orderbook = limitOrders_to_OrderBook(orders: action.data, pair: action.pair)
        state.data.accept(orderbook)

    default:
        break
    }

    return state
}

func limitOrders_to_OrderBook(orders: [LimitOrder], pair: Pair) -> OrderBook {
    var bids: [OrderBook.Order] = []
    var asks: [OrderBook.Order] = []

    var bidsTotalAmount: [Double] = []
    var asksTotalAmount: [Double] = []

    var combineOrders: [LimitOrder] = []

    var buyLastTradePrice = ""
    var sellLastTradePrice = ""

    //合并同样精度的委单
    for order in orders {
        let sellPriceBase = order.sellPrice.base

        var tradePrice:(price: String, pricision: Int, amountPricision: Int)!

        var isBuy: Bool!

        if sellPriceBase.assetID == pair.base {
            tradePrice = order.sellPrice.toReal().tradePrice()
            isBuy = true
        } else {
            tradePrice = (1.0 / order.sellPrice.toReal()).tradePrice()
            isBuy = false
        }

        var lastTradePrice = isBuy ? buyLastTradePrice : sellLastTradePrice

        if tradePrice.price == lastTradePrice {
            lastTradePrice = tradePrice.price

            let lastIndex = combineOrders.count - 1
            let lastOrder = combineOrders[lastIndex]

            lastOrder.forSale = "\(lastOrder.forSale.toDouble()! + order.forSale.toDouble()!)"
            combineOrders[lastIndex] = lastOrder
        } else {
            lastTradePrice = tradePrice.price
            combineOrders.append(order)
        }
        if isBuy {
            buyLastTradePrice = lastTradePrice
        } else {
            sellLastTradePrice = lastTradePrice
        }
    }

    for order in combineOrders {
        let sellPriceBase = order.sellPrice.base
        if sellPriceBase.assetID == pair.base {
            bidsTotalAmount.append(Double(order.forSale)!)
        } else {
            asksTotalAmount.append(Double(order.forSale)!)
        }
    }

    for order in combineOrders {
        let sellPriceBase = order.sellPrice.base
        if sellPriceBase.assetID == pair.base {
            let percent = bidsTotalAmount[0...bids.count].reduce(0, +) / bidsTotalAmount.reduce(0, +)

            let precisionRatio = pow(10, order.sellPrice.base.info().precision.double) / pow(10, order.sellPrice.quote.info().precision.double)

            let quoteForSale = Double(order.forSale)! / (precisionRatio * order.sellPrice.toReal())

            let quoteVolume = quoteForSale / pow(10.0, order.sellPrice.quote.info().precision.double)

            //      let isCYB = order.sellPrice.base.assetID == AssetConfiguration.CYB
            //      let price_precision = isCYB ? 5 : 8

            let tradePrice = order.sellPrice.toReal().tradePrice()
            let bid = OrderBook.Order(price: tradePrice.price, volume: quoteVolume.suffixNumber(digitNum: 10 - tradePrice.pricision), volumePercent: percent)
            bids.append(bid)
        } else {
            let percent = asksTotalAmount[0...asks.count].reduce(0, +) / asksTotalAmount.reduce(0, +)
            let quoteVolume = Double(order.forSale)! / pow(10, sellPriceBase.info().precision.double)

            //      let isCYB = order.sellPrice.quote.assetID == AssetConfiguration.CYB
            //      let price_precision = isCYB ? 5 : 8

            let tradePrice = (1.0 / order.sellPrice.toReal()).tradePrice()

            let ask = OrderBook.Order(price: tradePrice.price, volume: quoteVolume.suffixNumber(digitNum: 10 - tradePrice.pricision), volumePercent: percent)
            asks.append(ask)
        }
    }
    return OrderBook(bids: bids, asks: asks)
}
