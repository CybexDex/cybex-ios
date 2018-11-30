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
}

protocol MarketStateManagerProtocol {
    var state: MarketState { get }

    func setupChildViewControllers(_ pair: Pair) -> [BaseViewController]
    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair)
    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair)
    func setDropBoxViewController()
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
    
    func setupChildViewControllers(_ pair: Pair) -> [BaseViewController] {
        let vc = R.storyboard.main.orderBookViewController()!
        let coordinator = OrderBookCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        vc.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        
        let vc2 = R.storyboard.main.tradeHistoryViewController()!
        let coordinator2 = TradeHistoryCoordinator(rootVC: self.rootVC)
        vc2.coordinator = coordinator2
        vc2.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        
        refreshChildViewController([vc, vc2], pair: pair)
        
        return [vc, vc2]
    }
    
    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair) {
        for vc in vcs {
            if let vc = vc as? OrderBookViewController {
                vc.pair = pair
            } else if let vc = vc as? TradeHistoryViewController {
                vc.pair = pair
            }
        }
    }
}

extension MarketCoordinator: MarketStateManagerProtocol {
    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair) {
        self.rootVC.tabBarController?.selectedIndex = 2
        self.rootVC.popToRootViewController(animated: false)
        
        SwifterSwift.delay(milliseconds: 100) {
            if let baseNavi = self.rootVC.tabBarController?.viewControllers![2] as? BaseNavigationController, let vc = baseNavi.topViewController as? TradeViewController {
                vc.selectedIndex = isBuy ? 0 : 1
                vc.pair = pair
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
    
    func fetchLastMessageId(_ channel: String, callback:@escaping (Int)->()) {
        async {
            guard let data = try? await(SimpleHTTPService.fetchLastMessageIdWithChannel(channel)) else {
                return
            }
            main {
                callback(data)
            }
        }
    }
}
