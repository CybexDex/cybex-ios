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

let log = SwiftyBeaver.self
let reachability = Reachability()!
let navigator = Navigator()

fileprivate let UM_APPKEY = "5b6bf4a8b27b0a3429000016"

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
        if Defaults.hasKey(.frequency_type){
            UserManager.shared.frequency_type = UserManager.frequency_type(rawValue: Defaults[.frequency_type])!
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
        
        SimpleHTTPService.fetchHomeHotAssetJson()
        
        configApplication()
        
        if let url = launchOptions?[.url] as? URL {
            let opened = navigator.open(url)
            if !opened {
                navigator.present(url)
            }
        }
        return true
    }
    
    func fetchEtoHiddenRequest() {
        SimpleHTTPService.fetchETOHiddenRequest().done { (etoStatus) in
            AppConfiguration.shared.appCoordinator.etoStatus.accept(etoStatus)
            if let status = etoStatus, status.isETOEnabled == true {
                AppConfiguration.shared.appCoordinator.start()
            }
            }.catch { (error) in
        }
    }
    
    func setupAnalytics() {
        MobClick.setCrashReportEnabled(true)
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        UMConfigure.initWithAppkey(UM_APPKEY, channel: Bundle.main.bundleIdentifier!)

    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        if CybexWebSocketService.shared.checkNetworConnected() {
            if let vc = app_coodinator.startLoadingVC {
                app_coodinator.startLoadingVC = nil
                vc.endLoading()
            }
        }
        CybexWebSocketService.shared.disconnect()
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        app_coodinator.fetchPariTimer?.pause()
        app_coodinator.fetchPariTimer = nil
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let status = reachability.connection
        let reactable = (status != .none)
        
        if !CybexWebSocketService.shared.checkNetworConnected() && !CybexWebSocketService.shared.needAutoConnect && reactable {//避免第一次 不是主动断开的链接
            if let vc = app_coodinator.topViewController() {
                app_coodinator.startLoadingVC = vc
                vc.startLoading()
            }
            CybexWebSocketService.shared.connect()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
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
        }
        else {
            ThemeManager.setTheme(index: Defaults[.theme])
        }
        
        if !Defaults.hasKey(.language) {
            if let language = NSLocale.preferredLanguages.first, language == "zh-Hans-CN" {
                Localize.setCurrentLanguage("zh-Hans")
            }
            else {
                Localize.setCurrentLanguage("en")
            }
        }
        else {
            Localize.setCurrentLanguage(Defaults[.language])
        }
        
        app_data.ticker_data.asObservable()
            .subscribe(onNext: { (s) in
                if let vc = app_coodinator.startLoadingVC, !(vc is HomeViewController) {
                    app_coodinator.startLoadingVC = nil
                    vc.endLoading()
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc func handlerNetworkChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .none:
            CybexWebSocketService.shared.disconnect()
            if let vc = app_coodinator.startLoadingVC {
                app_coodinator.startLoadingVC = nil
                vc.endLoading()
            }
            
            _ = BeareadToast.showError(text: R.string.localizable.noNetwork.key.localized(), inView: self.window!, hide:2)
        default:
            if UserManager.shared.frequency_type == .normal {
                UserManager.shared.refreshTime = 6
            }else if UserManager.shared.frequency_type == .time {
                UserManager.shared.refreshTime = 3
            }else {
                if reachability.connection == .wifi {
                    UserManager.shared.refreshTime = 3
                }
                else {
                    UserManager.shared.refreshTime = 6
                }
            }
            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                if let vc = app_coodinator.topViewController() {
                    app_coodinator.startLoadingVC = vc
                    
                    vc.startLoading()
                }
                CybexWebSocketService.shared.connect()
                
                NotificationCenter.default.post(name: NotificationName.NetWorkChanged, object: nil)
            }
        }
    }
}
