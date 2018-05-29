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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var appCoordinator: AppCoordinator!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics.self, Answers.self])
    EasyAnimation.enable()
    
    self.window = UIWindow.init(frame: UIScreen.main.bounds)
    self.window?.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]

    self.window?.backgroundColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    
    KingfisherManager.shared.defaultOptions = [.fromMemoryCacheOrRefresh]
    
    _ = RichStyle.init()

    let rootVC = BaseTabbarViewController()
    window?.rootViewController = rootVC
    self.window?.makeKeyAndVisible()
    
    appCoordinator = AppCoordinator(rootVC: rootVC)
    
    self.appCoordinator.fetchEthToRmbPrice()
    appCoordinator.start()
    
//    appCoordinator.showLogin()
    RealReachability.sharedInstance().startNotifier()
    NotificationCenter.default.addObserver(forName: NSNotification.Name.realReachabilityChanged, object: nil, queue: nil) { (notifi) in
      self.handlerNetworkChanged()
      
    }
    
    configApplication()
    self.handlerNetworkChanged()
  
    return true
  }
  
  
  func applicationWillResignActive(_ application: UIApplication) {
    if WebsocketService.shared.checkNetworConnected() {
      if let vc = app_coodinator.startLoadingVC {
        app_coodinator.startLoadingVC = nil
        vc.endLoading()
      }
      WebsocketService.shared.disConnect()
    }
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
   
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    let status = RealReachability.sharedInstance().currentReachabilityStatus()
    let reactable = (status != .RealStatusNotReachable && status != .RealStatusUnknown)
    
    if !WebsocketService.shared.checkNetworConnected() && !WebsocketService.shared.needAutoConnect && reactable {//避免第一次 不是主动断开的链接
      if let vc = app_coodinator.topViewController() {
        app_coodinator.startLoadingVC = vc
        vc.startLoading()
      }
      WebsocketService.shared.reConnect()
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
      Localize.setCurrentLanguage("en")
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
      WebsocketService.shared.disConnect()
      if let vc = app_coodinator.startLoadingVC {
        app_coodinator.startLoadingVC = nil
        vc.endLoading()
      }
      
      _ = BeareadToast.showError(text: R.string.localizable.noNetwork.key.localized(), inView: self.window!, hide:2)
    }
    else {
      let connected = WebsocketService.shared.checkNetworConnected()
      if !connected {
        if let vc = app_coodinator.topViewController() {
          app_coodinator.startLoadingVC = vc
          
          vc.startLoading()
        }
        WebsocketService.shared.reConnect()
      }
    
    }
  }
}
