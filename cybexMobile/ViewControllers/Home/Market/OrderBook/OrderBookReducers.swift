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
    let state = state ?? OrderBookState()

    switch action {
    case let action as FetchedLimitData:
        let orderbook = limitOrders_to_OrderBook(orders: action.data, pair: action.pair)

        DispatchQueue.main.async {
            state.pair.accept(action.pair)
            state.data.accept(orderbook)
        }

    default:
        break
    }

    return state
}


func limitOrders_to_OrderBook(orders: [LimitOrder], pair: Pair) -> OrderBook {
    var bids: [OrderBook.Order] = []
    var asks: [OrderBook.Order] = []

    var bidsTotalAmount: [Decimal] = []
    var asksTotalAmount: [Decimal] = []

    var combineOrders: [[LimitOrder]] = [[],[]]

    var buyLastTradePrice = ""
    var sellLastTradePrice = ""

    //合并同样精度的委单
    for order in orders {
        let sellPriceBase = order.sellPrice.base
        var tradePrice:(price: String, pricision: Int, amountPricision: Int)!
        var isBuy: Bool!

        if sellPriceBase.assetID == pair.base {
            tradePrice = order.sellPrice.toReal().tradePriceAndAmountDecimal(.down)
            isBuy = true
        } else {
            tradePrice = (1.0 / order.sellPrice.toReal()).tradePriceAndAmountDecimal(.up)
            isBuy = false
        }
        var lastTradePrice = isBuy ? buyLastTradePrice : sellLastTradePrice
        if tradePrice.price.decimal() == lastTradePrice.decimal() {
            lastTradePrice = tradePrice.price
            let lastIndex = isBuy ? combineOrders[0].count - 1 : combineOrders[1].count - 1
            let lastOrder = isBuy ? combineOrders[0][lastIndex] : combineOrders[1][lastIndex]
            lastOrder.forSale = (lastOrder.forSale.decimal() + order.forSale.decimal()).stringValue
            lastOrder.sellPrice.quote.amount = (lastOrder.sellPrice.quote.amount.decimal() + order.sellPrice.quote.amount.decimal()).stringValue
            lastOrder.sellPrice.base.amount = (lastOrder.sellPrice.base.amount.decimal() + order.sellPrice.base.amount.decimal()).stringValue
            if isBuy {
                combineOrders[0][lastIndex] = lastOrder
            }
            else {
                combineOrders[1][lastIndex] = lastOrder
            }
        } else {
            lastTradePrice = tradePrice.price
            if isBuy {
                combineOrders[0].append(order)
            }
            else {
                combineOrders[1].append(order)
            }
        }
        if isBuy {
            buyLastTradePrice = lastTradePrice
        } else {
            sellLastTradePrice = lastTradePrice
        }
    }
    for order in combineOrders[0] {
        bidsTotalAmount.append(order.forSale.decimal())
    }

    for order in combineOrders[1] {
        asksTotalAmount.append(order.forSale.decimal())
    }
    
    for order in combineOrders[0] {
        let percent = bidsTotalAmount[0...bids.count].reduce(0, +) / bidsTotalAmount.reduce(0, +)
        let precisionRatio = pow(10, order.sellPrice.base.info().precision) / pow(10, order.sellPrice.quote.info().precision)
        let tradePrice = order.sellPrice.toReal().tradePriceAndAmountDecimal(.down)
        let quoteForSale = Decimal(string: order.forSale)! / (precisionRatio * order.sellPrice.toReal())
        let quoteVolume = quoteForSale / pow(10, order.sellPrice.quote.info().precision)
        let bid = OrderBook.Order(price: tradePrice.price.suffixNumber(digitNum: tradePrice.pricision,
                                                                       padZero: true),
                                  volume: quoteVolume.suffixNumber(digitNum: tradePrice.amountPricision),
                                  volumePercent: percent)
        bids.append(bid)
    }
    for order in combineOrders[1] {
        let sellPriceBase = order.sellPrice.base
        let percent = asksTotalAmount[0...asks.count].reduce(0, +) / asksTotalAmount.reduce(0, +)
        let quoteVolume = order.forSale.decimal() / pow(10, sellPriceBase.info().precision)

        let tradePrice = (1.0 / order.sellPrice.toReal()).tradePriceAndAmountDecimal(.up)
        
        let ask = OrderBook.Order(price: tradePrice.price.suffixNumber(digitNum: tradePrice.pricision,
                                                                       padZero: true),
                                  volume: quoteVolume.suffixNumber(digitNum: tradePrice.amountPricision),
                                  volumePercent: percent)
        asks.append(ask)
    }

//    for order in combineOrders {
//        let sellPriceBase = order.sellPrice.base
//        if sellPriceBase.assetID == pair.base {
//            let percent = bidsTotalAmount[0...bids.count].reduce(0, +) / bidsTotalAmount.reduce(0, +)
//
//            let precisionRatio = pow(10, order.sellPrice.base.info().precision) / pow(10, order.sellPrice.quote.info().precision)
//
//            let tradePrice = order.sellPrice.toRealDecimal().tradePriceDecimal(.down)
//
//            let quoteForSale = Decimal(string: order.forSale)! / (precisionRatio * tradePrice.price.toDecimal()!)
//
//            let quoteVolume = quoteForSale / pow(10, order.sellPrice.quote.info().precision)
//
//            print("priceprice : \(order.sellPrice.toRealDecimal())  , price : \(tradePrice.price)   amount: \(quoteVolume.stringValue)")
//
//
//            let bid = OrderBook.Order(price: tradePrice.price, volume: quoteVolume.stringValue.suffixNumber(digitNum: 10 - tradePrice.pricision), volumePercent: percent.doubleValue)
//            bids.append(bid)
//        } else {
//            let percent = asksTotalAmount[0...asks.count].reduce(0, +) / asksTotalAmount.reduce(0, +)
//            let quoteVolume = order.forSale.toDecimal()! / pow(10, sellPriceBase.info().precision)
//
//            //      let isCYB = order.sellPrice.quote.assetID == AssetConfiguration.CYB
//            //      let price_precision = isCYB ? 5 : 8
//
//            let tradePrice = (1.0 / order.sellPrice.toRealDecimal()).tradePriceDecimal(.up)
//
//            let ask = OrderBook.Order(price: tradePrice.price, volume: quoteVolume.stringValue.suffixNumber(digitNum: 10 - tradePrice.pricision), volumePercent: percent.doubleValue)
//            asks.append(ask)
//        }
//    }
    return OrderBook(bids: bids, asks: asks)
}



