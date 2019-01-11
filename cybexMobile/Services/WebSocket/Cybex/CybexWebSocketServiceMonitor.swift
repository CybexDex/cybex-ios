//
//  CybexWebSocketServiceMonitor.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability
import BeareadToast_swift

extension CybexWebSocketService {
    func monitor() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (notifi) in
            if CybexWebSocketService.shared.checkNetworConnected() {
                if let vc = appCoodinator.startLoadingVC {
                    appCoodinator.startLoadingVC = nil
                    vc.endLoading()
                }
            }
            CybexWebSocketService.shared.disconnect()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notifi) in
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


        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }

            switch reachability.connection {
            case .wifi, .cellular:
                let connected = CybexWebSocketService.shared.checkNetworConnected()
                if !connected {
                    if let vc = appCoodinator.topViewController() {
                        appCoodinator.startLoadingVC = vc

                        vc.startLoading()
                    }
                    CybexWebSocketService.shared.connect()
                }
            case .none:
                CybexWebSocketService.shared.disconnect()
                if let vc = appCoodinator.startLoadingVC {
                    appCoodinator.startLoadingVC = nil
                    vc.endLoading()
                }

                if let window = UIApplication.shared.delegate?.window as? UIWindow {
                    _ = BeareadToast.showError(text: R.string.localizable.noNetwork.key.localized(), inView: window, hide: 2)
                }
                break
            }

        }

        NotificationCenter.default.addObserver(forName: .NetWorkChanged, object: nil, queue: nil) { (note) in
            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                if let vc = appCoodinator.topViewController() {
                    appCoodinator.startLoadingVC = vc

                    vc.startLoading()
                }
                CybexWebSocketService.shared.connect()
            }
        }
    }
}
