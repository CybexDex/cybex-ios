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
import RxSwift
import SwiftyUserDefaults

enum AppEnv: String, CaseIterable {
    case product
    case test
    case uat

    static var current: AppEnv {
        return AppEnv(rawValue: Defaults[.environment]) ?? .product
    }

    var index: Int {
        for (i, env) in AppEnv.allCases.enumerated() {
            if self == env {
                return i
            }
        }

        return 0
    }
}

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
    var timer: Disposable?

    static let rmbPrecision = 4
    static let percentPrecision = 2
    static let amountPrecision = 2

    static let debounceDisconnectTime = 10

    private init() {
        let rootVC = BaseTabbarViewController()
        appCoordinator = AppCoordinator(rootVC: rootVC)

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.timer?.dispose()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            self.startFetchOuterPrice()
        }
    }

    static var ServerIconsBaseURLString = "https://app.cybex.io/icons/"
    static var GameBaseURLString = "https://gamecenter.cybex.io"

    static var HelpNightURL = "https://survey.cybex.io/cybexnight?lang="
    static var HelpLightURL = "https://survey.cybex.io/cybexday?lang="
}

extension AppConfiguration {
    func fetchAppEnableSettingRequest() {
        AppService.request(target: .setting, success: { (json) in
            let model = AppEnableSetting.deserialize(from: json.dictionaryObject)
            self.enableSetting.accept(model)

            AppConfiguration.shared.appCoordinator.start()

            self.appCoordinator.topViewController()?.handlerUpdateVersion(nil)
        }, error: { (_) in

        }) { (_) in

        }
    }

    func startFetchOuterPrice() {
        timer?.dispose()

        self.fetchOuterPrice()
        timer = Observable<Int>.interval(3, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (n) in
            guard let self = self else { return }
            self.fetchOuterPrice()

            Log.print(n, flag: "timer----")
        })
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

    func isAppStoreVersion() -> Bool {
        if let bundleID = Bundle.main.bundleIdentifier, bundleID.contains("fir") {
            return false
        }

        return true
    }
}

