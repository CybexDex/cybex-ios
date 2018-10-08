//
//  SettingCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyUserDefaults

protocol SettingCoordinatorProtocol {
    func openSettingDetail(type:settingPage)
    func dismiss()
    func openHelpWebView()
}

protocol SettingStateManagerProtocol {
    var state: SettingState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<SettingState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func changeEnveronment(_ callback:@escaping(Bool)->())
}

class SettingCoordinator: AccountRootCoordinator {
    
    lazy var creator = SettingPropertyActionCreate()
    
    var store = Store<SettingState>(
        reducer: SettingReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: SettingState {
        return store.state
    }
}

extension SettingCoordinator: SettingCoordinatorProtocol {
    func dismiss() {
        self.rootVC.popToRootViewController(animated: true)
    }
    
    func openSettingDetail(type:settingPage) {
        let vc = R.storyboard.main.settingDetailViewController()!
        vc.pageType = type
        let coordinator = SettingDetailCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }
    
    func openHelpWebView() {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc ,animated: true)
        }
    }
}

extension SettingCoordinator: SettingStateManagerProtocol {
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<SettingState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
    func changeEnveronment(_ callback:@escaping(Bool)->()) {
        var isTest = false
        if Defaults.hasKey(.environment) && Defaults[.environment] == "test" {
            Defaults[.environment] = ""
            isTest = false
        }
        else {
            Defaults[.environment] = "test"
            isTest = true
        }
        changeEnvironmentAction()
        AssetConfiguration.shared.asset_ids = []
        AssetConfiguration.shared.unique_ids = []
        
        app_data.data.accept([])

        CybexWebSocketService.shared.disconnect()
        UserManager.shared.logout()
        CybexWebSocketService.shared.connect()
        callback(isTest)
        self.rootVC.popViewController()
    }
}
