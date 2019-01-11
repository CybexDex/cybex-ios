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
    func openSettingDetail(type: SettingPage)
    func dismiss()
    func openHelpWebView()
    
}

protocol SettingStateManagerProtocol {
    var state: SettingState { get }

    func changeEnveronment(_ callback:@escaping(Bool) -> Void)
}

class SettingCoordinator: NavCoordinator {
    var store = Store<SettingState>(
        reducer: gSettingReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: SettingState {
        return store.state
    }
}

extension SettingCoordinator: SettingCoordinatorProtocol {
    func dismiss() {
        self.rootVC.popToRootViewController(animated: true)
    }

    func openSettingDetail(type: SettingPage) {
        let vc = R.storyboard.main.settingDetailViewController()!
        vc.pageType = type
        let coordinator = SettingDetailCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func openHelpWebView() {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension SettingCoordinator: SettingStateManagerProtocol {
    func changeEnveronment(_ callback:@escaping(Bool) -> Void) {
        var isTest = false
        if Defaults.hasKey(.environment) && Defaults[.environment] == "test" {
            Defaults[.environment] = ""
            isTest = false
        } else {
            Defaults[.environment] = "test"
            isTest = true
        }
//        MarketConfiguration.shared.marketPairs = []
//        AssetConfiguration.shared.whiteListOfIds = []
//
//        appData.tickerData.accept([])
//
//        CybexWebSocketService.shared.disconnect()
//        UserManager.shared.logout()
//        callback(isTest)
//        self.rootVC.popViewController()
//        if let appdelegate =  UIApplication.shared.delegate as? AppDelegate {
//            appdelegate.fetchEtoHiddenRequest(true)
//            CybexWebSocketService.shared.connect()
//        }
    }
}
