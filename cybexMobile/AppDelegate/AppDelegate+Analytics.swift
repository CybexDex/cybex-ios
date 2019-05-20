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
import Sentry

private let UMAppkey = "5b6bf4a8b27b0a3429000016"
private let SentrySN = "http://856bdd62a8f740f4bfa233870e1632a0@120.27.16.142:9000/15"

extension AppDelegate {
    func setupSentry() {
        do {
            Client.shared = try Client(dsn: SentrySN)
            Client.shared?.enableAutomaticBreadcrumbTracking()
            try Client.shared?.startCrashHandler()
        } catch let error {
            Log.print("\(error)")
        }

        UserManager.shared.name.asObservable().subscribe(onNext: { (account) in
            Client.shared?.user = User(userId: UserManager.shared.name.value ?? "Anonymity")
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        Client.shared?.user = User(userId: UserManager.shared.name.value ?? "Anonymity")
    }

    func setupAnalytics() {
        Fabric.with([Crashlytics.self, Answers.self])
        UserManager.shared.name.asObservable().subscribe(onNext: { (account) in
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

func sendStatEvent(_ message: String) {
    let event = Event(level: .error)
    event.message = message
    event.environment = AppEnv.current.rawValue
    event.extra = ["ios": true]
    Client.shared?.send(event: event)
}
