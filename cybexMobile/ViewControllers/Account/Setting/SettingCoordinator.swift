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
        UserManager.shared.logout()

        CybexWebSocketService.shared.disconnect()
        CybexConfiguration.shared.chainID.accept("")
        AppConfiguration.shared.enableSetting.accept(nil)
        AssetConfiguration.shared.whiteListOfIds.accept([])
        MarketConfiguration.shared.importMarketLists.accept([])
        AssetConfiguration.shared.quoteToProjectNames.accept([:])
        MarketConfiguration.shared.marketPairs.accept([])
        CybexWebSocketService.shared.canSendMessageReactive.accept(false)
        appData.tickerData.accept([])
        if Defaults.isTestEnv {
            Defaults[.environment] = ""
            callback(false)
        } else {
            Defaults[.environment] = "test"
            callback(true)
        }

        CybexWebSocketService.shared.connect()

        if let del = UIApplication.shared.delegate as? AppDelegate {
            del.checkSetting()
        }

    }
}
