//
//  AppDelegate+Analytics.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

private let UMAppkey = "5b6bf4a8b27b0a3429000016"

extension AppDelegate {
    func setupAnalytics() {
        Fabric.with([Crashlytics.self, Answers.self])
        UserManager.shared.account.asObservable().subscribe(onNext: { (account) in
            Crashlytics.sharedInstance().setUserName(UserManager.shared.name.value)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        Crashlytics.sharedInstance().setUserName(UserManager.shared.name.value)
        
        #if DEBUG
        Fabric.sharedSDK().debug = true
        #endif


        MobClick.setCrashReportEnabled(true)
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        UMConfigure.initWithAppkey(UMAppkey, channel: Bundle.main.bundleIdentifier!)
    }
}
