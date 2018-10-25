//
//  OrderBookReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func OrderBookReducer(action: Action, state: OrderBookState?) -> OrderBookState {
    return OrderBookState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: OrderBookPropertyReducer(state?.property, action: action))
}

func OrderBookPropertyReducer(_ state: OrderBookPropertyState?, action: Action) -> OrderBookPropertyState {
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

  var bids_total_amount: [Double] = []
  var asks_total_amount: [Double] = []

  var combineOrders: [LimitOrder] = []

  var buy_lastTradePrice = ""
  var sell_lastTradePrice = ""

  //合并同样精度的委单
  for order in orders {
    let sellPrice_base = order.sellPrice.base

    var tradePrice:(price: String, pricision: Int, amountPricision: Int)!

    var isBuy: Bool!

    if sellPrice_base.assetID == pair.base {
      tradePrice = order.sellPrice.toReal().tradePrice()
      isBuy = true
    } else {
      tradePrice = (1.0 / order.sellPrice.toReal()).tradePrice()
      isBuy = false
    }

    var lastTradePrice = isBuy ? buy_lastTradePrice : sell_lastTradePrice

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
      buy_lastTradePrice = lastTradePrice
    } else {
      sell_lastTradePrice = lastTradePrice
    }

  }

  for order in combineOrders {
    let sellPrice_base = order.sellPrice.base
    if sellPrice_base.assetID == pair.base {
      bids_total_amount.append(Double(order.forSale)!)
    } else {
      asks_total_amount.append(Double(order.forSale)!)
    }
  }

  for order in combineOrders {
    let sellPrice_base = order.sellPrice.base

    if sellPrice_base.assetID == pair.base {
      let percent = bids_total_amount[0...bids.count].reduce(0, +) / bids_total_amount.reduce(0, +)

      let precision_ratio = pow(10, order.sellPrice.base.info().precision.double) / pow(10, order.sellPrice.quote.info().precision.double)

      let quote_forSale = Double(order.forSale)! / (precision_ratio * order.sellPrice.toReal())

      let quote_volume = quote_forSale / pow(10.0, order.sellPrice.quote.info().precision.double)

//      let isCYB = order.sellPrice.base.assetID == AssetConfiguration.CYB
//      let price_precision = isCYB ? 5 : 8

      let tradePrice = order.sellPrice.toReal().tradePrice()
      let bid = OrderBook.Order(price: tradePrice.price, volume: quote_volume.suffixNumber(digitNum: 10 - tradePrice.pricision), volume_percent: percent)
      bids.append(bid)
    } else {
      let percent = asks_total_amount[0...asks.count].reduce(0, +) / asks_total_amount.reduce(0, +)
      let quote_volume = Double(order.forSale)! / pow(10, sellPrice_base.info().precision.double)

//      let isCYB = order.sellPrice.quote.assetID == AssetConfiguration.CYB
//      let price_precision = isCYB ? 5 : 8

      let tradePrice = (1.0 / order.sellPrice.toReal()).tradePrice()

      let ask = OrderBook.Order(price: tradePrice.price, volume: quote_volume.suffixNumber(digitNum: 10 - tradePrice.pricision), volume_percent: percent)
      asks.append(ask)
    }
  }

  return OrderBook(bids: bids, asks: asks)

}
