//
//  ComprehensiveCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import Localize_Swift

protocol ComprehensiveCoordinatorProtocol {

    func openWebVCUrl(_ url: String)

    func openMarketList(_ pair: Pair)
    
    func openChatVC()
}

protocol ComprehensiveStateManagerProtocol {
    var state: ComprehensiveState { get }

    func switchPageState(_ state: PageState)

    func fetchData()

    func fetchAnnounceInfos()

    func fetchHomeBannerInfos()

    func fetchHotAssetsInfos()

    func fetchMiddleItemInfos()

    func setupChildrenVC(_ sender: ComprehensiveViewController)
}

class ComprehensiveCoordinator: ComprehensiveRootCoordinator {
    var store = Store(
        reducer: comprehensiveReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ComprehensiveState {
        return store.state
    }

    override func register() {
        Broadcaster.register(ComprehensiveCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ComprehensiveStateManagerProtocol.self, observer: self)
    }
}

extension ComprehensiveCoordinator: ComprehensiveCoordinatorProtocol {
    // test
    func openChatVC() {
        // test
        if let chatVC = R.storyboard.chat.chatViewController() {
            chatVC.coordinator = ChatCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(chatVC, animated: true)
        }
    }
    
    
    func openWebVCUrl(_ url: String) {
        if let webVC = R.storyboard.main.cybexWebViewController() {
            webVC.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            webVC.vcType = .homeBanner
            webVC.url = URL(string: url)
            self.rootVC.pushViewController(webVC, animated: true)
        }
    }

    func openMarketList(_ pair: Pair) {
        if let marketVC = R.storyboard.main.marketViewController() {
            var currentBaseIndex = 0
            for index in 0..<AssetConfiguration.marketBaseAssets.count {
                if pair.base == AssetConfiguration.marketBaseAssets[index] {
                    currentBaseIndex = index
                }
            }
            let tickers = appData.filterQuoteAssetTicker(pair.base)
            var curIndex = 0
            for index in 0..<tickers.count {
                let ticker = tickers[index]
                if ticker.base == pair.base && ticker.quote == pair.quote {
                    curIndex = index
                }
            }
            marketVC.curIndex = curIndex
            marketVC.currentBaseIndex = currentBaseIndex
            marketVC.rechargeShowType = PairRechargeView.ShowType.show.rawValue
            let coordinator = MarketCoordinator(rootVC: self.rootVC)
            marketVC.coordinator = coordinator
            self.rootVC.pushViewController(marketVC, animated: true)
        }
    }
}

extension ComprehensiveCoordinator: ComprehensiveStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }

    func fetchData() {
        fetchAnnounceInfos()
        fetchHomeBannerInfos()
        fetchHotAssetsInfos()
        fetchMiddleItemInfos()
    }

    func fetchAnnounceInfos() {
        let url = AppConfiguration.AnnounceJson + (Localize.currentLanguage() == "en" ? "en" : "zh")
        SimpleHTTPService.fetchAnnounceJson(url).done { (data) in
            if let data = data {
                self.store.dispatch(FetchAnnouncesAction(data: data))
            }
            }.catch { (_) in
        }
    }

    func fetchHomeBannerInfos() {
        let url = AppConfiguration.HomeBannerJson + (Localize.currentLanguage() == "en" ? "en" : "zh")
        SimpleHTTPService.fetchHomeBannerInfos(url).done { (data) in
            if let data = data, data.count > 0 {
                self.store.dispatch(FetchHomeBannerAction(data: data))
            }
            }.catch { (_) in
        }
    }

    func fetchHotAssetsInfos() {
        SimpleHTTPService.fetchHomeHotAssetJson().done { (data) in
            if let data = data {
                self.store.dispatch(FetchHotAssetsAction(data: data))
            }
            }.catch { (_) in
        }
    }

    func fetchMiddleItemInfos() {
        let url = AppConfiguration.HomeItemsJson + (Localize.currentLanguage() == "en" ? "en" : "zh")
        SimpleHTTPService.fetchHomeItemInfo(url).done { (data) in
            if let data = data, data.count != 0 {
                self.store.dispatch(FetchMiddleItemAction(data: data))
            }
            }.catch { (_) in
        }
    }

    func setupChildrenVC(_ sender: ComprehensiveViewController) {
        if let homeVC = R.storyboard.main.homeViewController() {
            homeVC.coordinator = HomeCoordinator(rootVC: self.rootVC)
            homeVC.vcType = ViewType.comprehensive.rawValue
            sender.addChild(homeVC)
            sender.contentView.topGainersView.addSubview(homeVC.view)
            homeVC.contentView?.edges(to: sender.contentView.topGainersView)
            homeVC.didMove(toParent: sender)
        }
    }
}
