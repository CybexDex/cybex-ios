//
//  MarketCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwifterSwift

protocol MarketCoordinatorProtocol {
    func openChatVC(_ sender: Pair)
    func setupChildViewControllers(_ pair: Pair) -> [BaseViewController]
    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair)
    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair)
    func setDropBoxViewController()
}

protocol MarketStateManagerProtocol {
    var state: MarketState { get }

    func isExistProjectIntroduction(_ pair: Pair) -> Bool
    func requestKlineDetailData(pair: Pair, gap: Candlesticks)
    func fetchLastMessageId(_ channel: String, callback:@escaping (Int)->())
}

class MarketCoordinator: NavCoordinator {

    var store = Store<MarketState>(
        reducer: marketReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
    
    var state: MarketState {
        return store.state
    }
}

extension MarketCoordinator: MarketCoordinatorProtocol {
    func openChatVC(_ sender: Pair) {
        if let chatVC = R.storyboard.chat.chatViewController() {
            let coordinator = ChatCoordinator(rootVC: self.rootVC)
            chatVC.coordinator = coordinator
            chatVC.pair = sender
            self.rootVC.pushViewController(chatVC, animated: true)
        }
    }

    func isExistProjectIntroduction(_ pair: Pair) -> Bool {
        if let projectName = AssetConfiguration.shared.quoteToProjectNames.value[pair.quote.symbol], !projectName.isEmpty {
            return true
        }

        return false
    }
    
    func setupChildViewControllers(_ pair: Pair) -> [BaseViewController] {
        let vc = R.storyboard.main.orderBookViewController()!
        vc.pair = pair
        let coordinator = OrderBookCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        vc.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        
        let vc2 = R.storyboard.main.tradeHistoryViewController()!
        vc2.pair = pair
        let coordinator2 = TradeHistoryCoordinator(rootVC: self.rootVC)
        vc2.coordinator = coordinator2
        vc2.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        
        refreshChildViewController([vc, vc2], pair: pair)

        if isExistProjectIntroduction(pair) {
            let vc3 = R.storyboard.eva.evaViewController()!
            if let marketVC = self.rootVC.topViewController as? MarketViewController {
                vc3.parentVC = marketVC
            }

            vc3.tokenName = pair.quote.symbol

            if let projectName = AssetConfiguration.shared.quoteToProjectNames.value[pair.quote.symbol], !projectName.isEmpty {
                vc3.projectName = projectName
            }
            vc3.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

            return [vc, vc2, vc3]
        }
        else {
            return [vc, vc2]
        }
    }
    
    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair) {
        for vc in vcs {
            if let vc = vc as? TradeHistoryViewController {
                vc.refresh()
            }
        }
    }

    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair) {
        self.rootVC.tabBarController?.selectedIndex = 2
        self.rootVC.popToRootViewController(animated: false)

        SwifterSwift.delay(milliseconds: 100) {
            if let baseNavi = self.rootVC.tabBarController?.viewControllers![2] as? BaseNavigationController, let vc = baseNavi.topViewController as? TradeViewController {
                vc.pair = pair
                vc.selectedIndex = isBuy ? 0 : 1
                vc.titlesView?.selectedIndex = vc.selectedIndex
            }
        }

    }

    func setDropBoxViewController() {
        guard let vc = R.storyboard.comprehensive.recordChooseViewController(),
            let marketVC = self.rootVC.topViewController as? MarketViewController,
            let selectedView = marketVC.selectedDropKindView else { return }
        vc.preferredContentSize = CGSize(width: selectedView.width, height: selectedView.dropKind == .time ? 102 : 136)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.popoverBackgroundViewClass = CybexPopoverBackgroundView.self
        vc.popoverPresentationController?.sourceView = selectedView
        vc.popoverPresentationController?.sourceRect = selectedView.bounds
        vc.popoverPresentationController?.delegate = marketVC
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        vc.popoverPresentationController?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        vc.typeIndex = selectedView.dropKind == .time ? .time : .kind
        vc.delegate = marketVC
        vc.coordinator = RecordChooseCoordinator(rootVC: self.rootVC)
        marketVC.present(vc, animated: true) {
            vc.view.superview?.cornerRadius = 2
        }
    }
}

extension MarketCoordinator: MarketStateManagerProtocol {
    func requestKlineDetailData(pair: Pair, gap: Candlesticks) {
        let now = Date()
        let start = now.addingTimeInterval(TimeInterval(-gap.rawValue * 199))

        let queryItem = AssetPairQueryParams(firstAssetId: pair.base,
                                            secondAssetId: pair.quote,
                                            timeGap: gap.rawValue,
                                            startTime: start,
                                            endTime: now)

        let request = GetMarketHistoryRequest(queryParams: queryItem) { response in
            if let buckets = response as? [Bucket] {
                self.handlerKlines(queryItem, data: buckets)
            }
        }

        CybexWebSocketService.shared.send(request: request, priority: .normal)
    }

    func handlerKlines(_ queryItem: AssetPairQueryParams, data: [Bucket]) {
        var data = data
        guard data.count > 0 else {
            self.store.dispatch(KLineFetched(pair: Pair(base: queryItem.firstAssetId, quote: queryItem.secondAssetId), stick: Candlesticks(rawValue: queryItem.timeGap)!, assets: []))
            return
        }

        let firstTrade = data[0]

        guard firstTrade.open > queryItem.startTime.timeIntervalSince1970 else {
            self.store.dispatch(KLineFetched(pair: Pair(base: queryItem.firstAssetId, quote: queryItem.secondAssetId), stick: Candlesticks(rawValue: queryItem.timeGap)!, assets:data))
            return
        }

        var params = queryItem
        params.startTime = queryItem.startTime.addingTimeInterval(TimeInterval(-queryItem.timeGap * 199))
        params.endTime = queryItem.startTime

        let request = GetMarketHistoryRequest(queryParams: params) { response in
            if let buckets = response as? [Bucket], let bucket = buckets.last {
                let close = bucket.openBase
                let quoteClose = bucket.openQuote
                if let addAsset = bucket.copy() as? Bucket {
                    addAsset.closeBase = close
                    addAsset.closeQuote = quoteClose
                    addAsset.openBase = close
                    addAsset.openQuote = quoteClose
                    addAsset.highBase = close
                    addAsset.highQuote = quoteClose
                    addAsset.lowBase = close
                    addAsset.lowQuote = quoteClose
                    addAsset.baseVolume = "0"
                    addAsset.quoteVolume = "0"
                    addAsset.open = params.startTime.timeIntervalSince1970
                    data.prepend(addAsset)
                }
            }

            self.store.dispatch(KLineFetched(pair: Pair(base: params.firstAssetId, quote: params.secondAssetId), stick: Candlesticks(rawValue: params.timeGap)!, assets:data))

        }
        CybexWebSocketService.shared.send(request: request, priority: .normal)
    }

    func fetchLastMessageId(_ channel: String, callback:@escaping (Int)->()) {
        IMService.request(target: IMAPI.messageCount(channel), success: { (json) in
            callback(json.intValue)
        }, error: { (_) in

        }) { (_) in

        }
    }
}
