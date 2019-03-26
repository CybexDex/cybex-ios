//
//  AppDelegate.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import UIKit
import Flutter
import FlutterPluginRegistrant // Only if you have Flutter Plugins.

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    var flutterEngine : FlutterEngine?

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.flutterEngine = FlutterEngine(name: "io.flutter", project: nil)
        self.flutterEngine?.run(withEntrypoint: nil)
        GeneratedPluginRegistrant.register(with: self.flutterEngine)

        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable") //隐藏 constraint log

        setupAnalytics()
        setupThirdParty()
        setupLog()

        setupUserSetting()
        setupUI()

        monitorNetwork() //网络权限
        requestSetting()

        start()

//        let vc = R.storyboard.eva.evaViewController()!
//        vc.view.backgroundColor = UIColor.darkTwo
//        window?.rootViewController = vc

        if let url = launchOptions?[.url] as? URL {
            let opened = navigator.open(url)
            if !opened {
                navigator.present(url)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if navigator.open(url) {
            return true
        }

        if navigator.present(url, wrap: UINavigationController.self) != nil {
            return true
        }

        return false
    }

}
