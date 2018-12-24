//
//  AppConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import RxCocoa
import Repeat

var appData: AppPropertyState {
    return appState.property
}
var appState: AppState {
    return AppConfiguration.shared.appCoordinator.state
}
var appCoodinator: AppCoordinator {
    return AppConfiguration.shared.appCoordinator
}

class AppConfiguration {
    static let shared = AppConfiguration()

    var enableSetting: BehaviorRelay<AppEnableSetting?> = BehaviorRelay(value: nil)
    var rmbPrices: BehaviorRelay<[RMBPrices]> = BehaviorRelay(value: [])

    var appCoordinator: AppCoordinator!
    var timer: Repeater?

    static let rmbPrecision = 4
    static let percentPrecision = 2
    static let amountPrecision = 2

    private init() {
        let rootVC = BaseTabbarViewController()
        appCoordinator = AppCoordinator(rootVC: rootVC)
    }

    static var ServerIconsBaseURLString = "https://app.cybex.io/icons/"

    static var HelpNightURL = "http://47.75.154.39:3009/cybexnight?lang="
    static var HelpLightURL = "http://47.75.154.39:3009/cybexday?lang="
}

extension AppConfiguration {
    func fetchAppEnableSettingRequest() {
        AppService.request(target: .setting, success: { (json) in
            let model = AppEnableSetting.deserialize(from: json.dictionaryObject)
            self.enableSetting.accept(model)

            AppConfiguration.shared.appCoordinator.start()
        }, error: { (_) in

        }) { (_) in

        }
    }

    func startFetchOuterPrice() {
        self.timer?.pause()
        self.timer = nil

        self.fetchOuterPrice()

        self.timer = Repeater.every(.seconds(3)) {[weak self] _ in
            guard let self = self else { return }
            self.fetchOuterPrice()
        }
        timer?.start()

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (note) in
            self.timer?.pause()
            self.timer = nil
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            self.startFetchOuterPrice()
        }
    }

    private func fetchOuterPrice() {
        AppService.request(target: AppAPI.outerPrice, success: { (json) in
            let prices = json["prices"].arrayValue.compactMap( { RMBPrices.deserialize(from: $0.dictionaryObject) } )

            if prices.count > 0 {
                self.rmbPrices.accept(prices)
            }
        }, error: { (_) in
        }) { (_) in
        }
    }
}

