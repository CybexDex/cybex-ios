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
import Async
import Localize_Swift

protocol ComprehensiveCoordinatorProtocol {
    
    func openWebVCUrl(_ url: String)
    
    func openMarketList(_ pair: Pair)
}

protocol ComprehensiveStateManagerProtocol {
    var state: ComprehensiveState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchData()
    
    func fetchAnnounceInfos()
    
    func fetchHomeBannerInfos()
    
    func fetchHotAssetsInfos()
    
    func fetchMiddleItemInfos()
    
    func setupChildrenVC(_ sender: ComprehensiveViewController)
}

class ComprehensiveCoordinator: ComprehensiveRootCoordinator {
    var store = Store(
        reducer: ComprehensiveReducer,
        state: nil,
        middleware:[TrackingMiddleware]
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
    func openWebVCUrl(_ url: String) {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            vc.vc_type = .homeBanner
            vc.url = URL(string: url)
            self.rootVC.pushViewController(vc ,animated: true)
        }
    }
    
    func openMarketList(_ pair: Pair) {
        let vc = R.storyboard.main.marketViewController()!
        var currentBaseIndex = 0
        for index in 0..<AssetConfiguration.market_base_assets.count {
            if pair.base == AssetConfiguration.market_base_assets[index] {
               currentBaseIndex = index
            }
        }
        let homeBuckets = app_data.filterQuoteAsset(pair.base)
        var curIndex = 0
        for index in 0..<homeBuckets.count {
            let homebucket = homeBuckets[index]
            if homebucket.base == pair.base && homebucket.quote == pair.quote {
                curIndex = index
            }
        }
        vc.curIndex = curIndex
        vc.currentBaseIndex = currentBaseIndex
        vc.rechargeShowType = PairRechargeView.show_type.show.rawValue
        let coordinator = MarketCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }
}

extension ComprehensiveCoordinator: ComprehensiveStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        Async.main {
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
        let url = AppConfiguration.ANNOUNCE_JSON + (Localize.currentLanguage() == "en" ? "en" : "zh")
        SimpleHTTPService.fetchAnnounceJson(url).done { (data) in
            if let data = data {
                self.store.dispatch(FetchAnnouncesAction(data: data))
            }
            }.catch { (error) in
        }
    }
    
    func fetchHomeBannerInfos() {
        let url = AppConfiguration.HOME_BANNER_JSON + (Localize.currentLanguage() == "en" ? "en" : "zh")
        SimpleHTTPService.fetchHomeBannerInfos(url).done { (data) in
            if let data = data {
                self.store.dispatch(FetchHomeBannerAction(data: data))
            }
            }.catch { (error) in
        }
    }
    
    func fetchHotAssetsInfos() {
        SimpleHTTPService.fetchHomeHotAssetJson().done { (data) in
            if let data = data {
                self.store.dispatch(FetchHotAssetsAction(data: data))
            }
            }.catch { (error) in
        }
    }
    
    func fetchMiddleItemInfos() {
        let url = AppConfiguration.HOME_ITEMS_JSON + (Localize.currentLanguage() == "en" ? "en" : "zh")
        SimpleHTTPService.fetchHomeItemInfo(url).done { (data) in
            if let data = data, data.count != 0 {
                self.store.dispatch(FetchMiddleItemAction(data: data))
            }
            }.catch { (error) in
        }
    }
    
    func setupChildrenVC(_ sender: ComprehensiveViewController) {
        if let homeVC = R.storyboard.main.homeViewController(){
            homeVC.coordinator = HomeCoordinator(rootVC: self.rootVC)
            homeVC.VC_TYPE = view_type.Comprehensive.rawValue
            sender.addChild(homeVC)
            sender.contentView.topGainersView.addSubview(homeVC.view)
            homeVC.contentView?.edges(to: sender.contentView.topGainersView)
            homeVC.didMove(toParent: sender)
        }
    }
}
