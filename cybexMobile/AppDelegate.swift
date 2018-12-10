//
//  AppDelegate.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import UIKit

import Localize_Swift
import SwiftTheme
import Reachability
import SwiftyUserDefaults
import BeareadToast_swift
import IQKeyboardManagerSwift
import Kingfisher

import Fabric
import Crashlytics
import SwiftRichString
import SwiftyBeaver
import AlamofireNetworkActivityLogger
import NBLCommonModule
import ChatRoom

let log = SwiftyBeaver.self
let reachability = Reachability()!
let navigator = Navigator()

private let UMAppkey = "5b6bf4a8b27b0a3429000016"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self, Answers.self])
        #if DEBUG
        Fabric.sharedSDK().debug = true
        #endif
        URLNavigationMap.initialize(navigator: navigator)

        setupAnalytics()

        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .error
        if Defaults.hasKey(.frequencyType) {
            UserManager.shared.frequencyType = UserManager.FrequencyType(rawValue: Defaults[.frequencyType])!
        }
        changeEnvironmentAction()

        let cache = KingfisherManager.shared.cache
        cache.clearDiskCache()
        cache.clearMemoryCache()
        cache.cleanExpiredDiskCache()

        let console = ConsoleDestination()
        log.addDestination(console)
        //    let file = FileDestination()
        //    file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        //    log.addDestination(file)
        RichStyle.shared.start()

        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]

        self.window?.backgroundColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        //    KingfisherManager.shared.defaultOptions = [.fromMemoryCacheOrRefresh]

        window?.rootViewController = AppConfiguration.shared.appCoordinator.rootVC
        self.window?.makeKeyAndVisible()

        AppConfiguration.shared.appCoordinator.fetchEthToRmbPrice()
        AppConfiguration.shared.appCoordinator.start()
        self.fetchEtoHiddenRequest()

        ZYNetworkAccessibity.setAlertEnable(true)
        ZYNetworkAccessibity.setStateDidUpdateNotifier { (state) in
            if state == ZYNetworkAccessibleState.accessible {
                self.fetchEtoHiddenRequest()
                NotificationCenter.default.post(name: NotificationName.NetWorkChanged, object: nil)
            }
        }
        ZYNetworkAccessibity.start()

        NotificationCenter.default.addObserver(self, selector: #selector(handlerNetworkChanged(note:)), name: .reachabilityChanged, object: reachability)

        //        RealReachability.sharedInstance().startNotifier()
        //        NotificationCenter.default.addObserver(forName: NSNotification.Name.realReachabilityChanged, object: nil, queue: nil) { (notifi) in
        //            main {
        //                self.handlerNetworkChanged()
        //            }
        //        }
        try? reachability.startNotifier()

        configApplication()

        if let url = launchOptions?[.url] as? URL {
            let opened = navigator.open(url)
            if !opened {
                navigator.present(url)
            }
        }
        return true
    }

    func fetchEtoHiddenRequest(_ refresh:Bool = false) {
        AppService.request(target: .setting, success: { (json) in
            let model = ETOHidden.deserialize(from: json.dictionaryObject)
            AppConfiguration.shared.appCoordinator.etoStatus.accept(model)
            if let status = model, status.isETOEnabled == true {
                AppConfiguration.shared.appCoordinator.start()
            } else if refresh {
                AppConfiguration.shared.appCoordinator.start()
            }
        }, error: { (_) in

        }) { (_) in

        }
    }

    func setupAnalytics() {
        MobClick.setCrashReportEnabled(true)
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        UMConfigure.initWithAppkey(UMAppkey, channel: Bundle.main.bundleIdentifier!)

    }

    func applicationWillResignActive(_ application: UIApplication) {
        if CybexWebSocketService.shared.checkNetworConnected() {
            if let vc = appCoodinator.startLoadingVC {
                appCoodinator.startLoadingVC = nil
                vc.endLoading()
            }
        }
        CybexWebSocketService.shared.disconnect()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        appCoodinator.fetchPariTimer?.pause()
        appCoodinator.fetchPariTimer = nil
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let status = reachability.connection
        let reactable = (status != .none)

        if !CybexWebSocketService.shared.checkNetworConnected() && !CybexWebSocketService.shared.needAutoConnect && reactable {//避免第一次 不是主动断开的链接
            if let vc = appCoodinator.topViewController() {
                appCoodinator.startLoadingVC = vc
                vc.startLoading()
            }
            CybexWebSocketService.shared.connect()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // URLNavigator Handler
        if navigator.open(url) {
            return true
        }

        // URLNavigator View Controller
        if navigator.present(url, wrap: UINavigationController.self) != nil {
            return true
        }

        return false
    }

}

extension AppDelegate {
    func configApplication() {
        UIApplication.shared.theme_setStatusBarStyle([.lightContent, .default], animated: true)

        if !Defaults.hasKey(.theme) {
            ThemeManager.setTheme(index: 0)
        } else {
            ThemeManager.setTheme(index: Defaults[.theme])
        }

        if !Defaults.hasKey(.language) {
            if let language = NSLocale.preferredLanguages.first, language == "zh-Hans-CN" {
                Localize.setCurrentLanguage("zh-Hans")
            } else {
                Localize.setCurrentLanguage("en")
            }
        } else {
            Localize.setCurrentLanguage(Defaults[.language])
        }

        appData.tickerData.asObservable()
            .subscribe(onNext: { (_) in
                if let vc = appCoodinator.startLoadingVC, !(vc is HomeViewController) {
                    appCoodinator.startLoadingVC = nil
                    vc.endLoading()
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    @objc func handlerNetworkChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }

        switch reachability.connection {
        case .none:
            CybexWebSocketService.shared.disconnect()
            if let vc = appCoodinator.startLoadingVC {
                appCoodinator.startLoadingVC = nil
                vc.endLoading()
            }

            _ = BeareadToast.showError(text: R.string.localizable.noNetwork.key.localized(), inView: self.window!, hide: 2)
        default:
            if UserManager.shared.frequencyType == .normal {
                UserManager.shared.refreshTime = 6
            } else if UserManager.shared.frequencyType == .time {
                UserManager.shared.refreshTime = 3
            } else {
                if reachability.connection == .wifi {
                    UserManager.shared.refreshTime = 3
                } else {
                    UserManager.shared.refreshTime = 6
                }
            }
            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                if let vc = appCoodinator.topViewController() {
                    appCoodinator.startLoadingVC = vc

                    vc.startLoading()
                }
                CybexWebSocketService.shared.connect()
                NotificationCenter.default.post(name: NotificationName.NetWorkChanged, object: nil)
            }

        }
    }
}
