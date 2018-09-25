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
}

protocol ComprehensiveStateManagerProtocol {
    var state: ComprehensiveState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchData()
    
    func fetchAnnounceInfos()
    
    func fetchHomeBannerInfos()
    
    func fetchHotAssetsInfos()
    
    func fetchMiddleItemInfos()
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
}
