//
//  OrderBookCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyJSON
import Reachability

protocol OrderBookCoordinatorProtocol {
    
    func openDecimalNumberVC(_ sender: UIView, maxDecimal: Int, selectedDecimal: Int, senderVC: OrderBookViewController)
    func openChooseTradeViewShowTypeVC(_ sender: UIView, selectedIndex: Int, senderVC: OrderBookViewController)
}

protocol OrderBookStateManagerProtocol {
    var state: OrderBookState { get }

    func subscribe(_ pair: Pair, depth: Int, count: Int)
    func unSubscribe(_ pair: Pair ,depth: Int ,count: Int)
    func resetData(_ pair: Pair)
    func switchShowType(_ index: Int)
    func updateMarketListHeight(_ height: CGFloat)
}

class OrderBookCoordinator: NavCoordinator {
    var store = Store<OrderBookState>(
        reducer: orderBookReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var popoverVC: RecordChooseViewController?

    override func register() {
       
    }
}

extension OrderBookCoordinator: OrderBookCoordinatorProtocol {
    func openDecimalNumberVC(_ sender: UIView, maxDecimal: Int, selectedDecimal: Int, senderVC: OrderBookViewController) {        
        let count = (maxDecimal + 1) / 4 != 0 ? 4 : (maxDecimal + 1) % 4
        
        guard let vc = R.storyboard.comprehensive.recordChooseViewController() else { return }

        vc.typeIndex = .orderbook
        vc.delegate = senderVC
        vc.maxCount = maxDecimal
        vc.count = count
        vc.selectedIndex = selectedDecimal - (maxDecimal + 1 - count)
        vc.coordinator = RecordChooseCoordinator(rootVC: self.rootVC)

        popoverVC?.dismiss(animated: false, completion: nil)
        popoverVC = vc
        senderVC.presentPopOverViewController(vc, size: CGSize(width: 82, height: 35 * count), sourceView: sender, offset: CGPoint(x: 0, y: 0), direction: .down)
    }

    func openChooseTradeViewShowTypeVC(_ sender: UIView, selectedIndex: Int, senderVC: OrderBookViewController) {
        guard let vc = R.storyboard.comprehensive.recordChooseViewController() else { return }

        vc.typeIndex = .tradeShowType
        vc.delegate = senderVC
        vc.selectedIndex = selectedIndex
        vc.coordinator = RecordChooseCoordinator(rootVC: self.rootVC)

        popoverVC?.dismiss(animated: false, completion: nil)
        popoverVC = vc
        senderVC.presentPopOverViewController(vc, size: CGSize(width: 82, height: 104), sourceView: sender, offset: CGPoint(x: 0, y: 0), direction: .down)
    }
}

extension OrderBookCoordinator: OrderBookStateManagerProtocol {
    var state: OrderBookState {
        return store.state
    }

    func subscribe(_ pair: Pair, depth: Int, count: Int) {
        guard let baseInfo = appData.assetInfo[pair.base],
            let quoteInfo = appData.assetInfo[pair.quote] else { return }
      
        self.store.dispatch(ChangeOrderBookOfPairAction(pair: pair))
        self.store.dispatch(ChangeDepthAndCountAction(depth: depth, count: count))

        let request = GetLimitOrdersRequest(pair: Pair(base: pair.base, quote: pair.quote)) { (resultObject) in
            DispatchQueue.global().async {
                let items = JSON(resultObject).arrayValue.compactMap( { LimitOrder.deserialize(from: $0.dictionaryObject) } )
            
                var bidLimitOrder: [LimitOrder] = []
                var askLimitOrder: [LimitOrder] = []
                
                var bid_levels: [PriceLevel] = []
                var ask_levels: [PriceLevel] = []

                for item in items {
                    item.baseID = pair.base
                    if (item.direction == "sell") {
                        askLimitOrder.append(item)
                    } else {
                        bidLimitOrder.append(item)
                    }
                }
                
                for o in askLimitOrder {
                    if ask_levels.last?.price != o.price.string(digits: depth, roundingMode: .up) {
                        ask_levels.append(PriceLevel(price: o.price.string(digits: depth, roundingMode: .up), amount: o.left_amount))
                    } else {
                        ask_levels[ask_levels.count - 1].addMount(m: o.left_amount)
                    }
                }
                
                for o in bidLimitOrder {
                    if bid_levels.last?.price != o.price.string(digits: depth, roundingMode: .down) {
                        bid_levels.append(PriceLevel(price: o.price.string(digits: depth, roundingMode: .down), amount: o.left_amount))
                    } else {
                        bid_levels[bid_levels.count - 1].addMount(m: o.left_amount)
                    }
                }
                
               
                var bids: [OrderBook.Order] = []
                var asks: [OrderBook.Order] = []
                var bidsTotalAmount:Decimal = 0
                var asksTotalAmount:Decimal = 0
                
                for lvl in ask_levels {
                    asks.append(OrderBook.Order(price: lvl.price, volume: lvl.amount, volumePercent: 0))
                    asksTotalAmount += lvl.amount
                    if (asks.count == count) {
                        break
                    }
                }
                
                for lvl in bid_levels {
                    bids.append(OrderBook.Order(price: lvl.price, volume: lvl.amount, volumePercent: 0))
                    bidsTotalAmount += lvl.amount
                    if (bids.count == count) {
                        break
                    }
                }

                bids = bids.map { (o) -> OrderBook.Order in
                    return OrderBook.Order(price: o.price,
                                           volume: o.volume,
                                           volumePercent: o.volume / bidsTotalAmount)
                }
                asks = asks.map { (o) -> OrderBook.Order in
                    return OrderBook.Order(price: o.price,
                                           volume: o.volume,
                                           volumePercent: o.volume / asksTotalAmount)
                }
                
                let orderbook = OrderBook(bids: bids, asks: asks)
                DispatchQueue.main.async {
                    self.store.dispatch(FetchedOrderBookData(data: orderbook, pair: pair))
                }
            }
            
            
        }
        
        CybexWebSocketService.shared.send(request: request)
        
        let latestPriceRequest = GetFillOrderHistoryRequest(pair: pair) { (response) in
            let data = JSON(response).arrayValue
            if (data.count > 0) {
                let operation = data[0]["op"]
                let base = operation["fill_price"]["base"]
                let quote = operation["fill_price"]["quote"]
              
                let basePrecision = pow(10, baseInfo.precision)
                let quotePrecision = pow(10, quoteInfo.precision)

                if base["asset_id"].stringValue == pair.base {
                    let quoteVolume = Decimal(string: quote["amount"].stringValue)! / quotePrecision
                    let baseVolume = Decimal(string: base["amount"].stringValue)! / basePrecision
                    let price = baseVolume / quoteVolume
                    self.store.dispatch(FetchLastPriceAction(price: price, pair: pair))
                } else {
                    let quoteVolume = Decimal(string: base["amount"].stringValue)! / quotePrecision
                    let baseVolume = Decimal(string: quote["amount"].stringValue)! / basePrecision
                    let price = baseVolume / quoteVolume
                    self.store.dispatch(FetchLastPriceAction(price: price, pair: pair))
                }
            }
        }

        CybexWebSocketService.shared.send(request: latestPriceRequest)

    }
    
    func unSubscribe(_ pair: Pair ,depth: Int ,count: Int) {
       
    }

    func switchShowType(_ index: Int) {
        self.store.dispatch(ChangeShowTypeIndexAction(index: index))
    }


    func resetData(_ pair: Pair) {
        self.store.dispatch(FetchedOrderBookData(data: nil, pair: pair))
        self.store.dispatch(ResetTickerAction())
        self.store.dispatch(ChangeDepthAndCountAction(depth: 0, count: 10))
    }

    func updateMarketListHeight(_ height: CGFloat) {
        if let vc = self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] as? MarketViewController {
            vc.pageContentViewHeight.constant = height
        }
    }

}
