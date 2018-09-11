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
import RealReachability
import SwiftyUserDefaults
import BeareadToast
import EasyAnimation
import IQKeyboardManagerSwift
import Kingfisher

import Fabric
import Crashlytics
import SwiftRichString
import SwiftyBeaver
import AlamofireNetworkActivityLogger
import NBLCommonModule

let log = SwiftyBeaver.self

fileprivate let UM_APPKEY = "5b6bf4a8b27b0a3429000016"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics.self, Answers.self])
    EasyAnimation.enable()
    
    setupAnalytics()
    
    NetworkActivityLogger.shared.startLogging()
    NetworkActivityLogger.shared.level = .error
    if Defaults.hasKey(.frequency_type){
      UserManager.shared.frequency_type = UserManager.frequency_type(rawValue: Defaults[.frequency_type])!
    }
    changeEnvironmentAction()
    
      
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
    
    RealReachability.sharedInstance().startNotifier()
    NotificationCenter.default.addObserver(forName: NSNotification.Name.realReachabilityChanged, object: nil, queue: nil) { (notifi) in
      main {
        self.handlerNetworkChanged()
      }
    }
    
    configApplication()
    self.handlerNetworkChanged()
    
    return true
  }
  
  func setupAnalytics() {
    UMCommonLogManager.setUp()
    MobClick.setCrashReportEnabled(true)
    UMConfigure.setLogEnabled(true)
    UMConfigure.setEncryptEnabled(true)
    UMConfigure.initWithAppkey(UM_APPKEY, channel: "fir")
    
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
    let status = RealReachability.sharedInstance().currentReachabilityStatus()
    let reactable = (status != .RealStatusNotReachable && status != .RealStatusUnknown)
    
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
    
    app_data.data.asObservable()
      .subscribe(onNext: { (s) in
        if let vc = app_coodinator.startLoadingVC, !(vc is HomeViewController) {
          app_coodinator.startLoadingVC = nil
          vc.endLoading()
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  func handlerNetworkChanged() {
    let status = RealReachability.sharedInstance().currentReachabilityStatus()
    if status == .RealStatusNotReachable || status  == .RealStatusUnknown {
      CybexWebSocketService.shared.disconnect()
      if let vc = app_coodinator.startLoadingVC {
        app_coodinator.startLoadingVC = nil
        vc.endLoading()
      }
      
      _ = BeareadToast.showError(text: R.string.localizable.noNetwork.key.localized(), inView: self.window!, hide:2)
    }
    else {
      if UserManager.shared.frequency_type == .normal {
        UserManager.shared.refreshTime = 6
      }else if UserManager.shared.frequency_type == .time {
        UserManager.shared.refreshTime = 3
      }else {
        if status == .RealStatusViaWiFi {
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
      }
    }
  }
}
