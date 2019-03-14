//
//  CybexWebSocketServiceMonitor.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability

extension CybexWebSocketService {
    func monitor() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (notifi) in
            CybexWebSocketService.shared.disconnect()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notifi) in
            let status = reachability.connection
            let reactable = (status != .none)

            if !CybexWebSocketService.shared.checkNetworConnected() && !CybexWebSocketService.shared.needAutoConnect && reactable {//避免第一次 不是主动断开的链接

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
                    CybexWebSocketService.shared.connect()
                }
            case .none:
                CybexWebSocketService.shared.disconnect()

                UIHelper.showErrorTop(R.string.localizable.noNetwork.key.localized())
                break
            }

        }

        NotificationCenter.default.addObserver(forName: .NetWorkChanged, object: nil, queue: nil) { (note) in
            let connected = CybexWebSocketService.shared.checkNetworConnected()
            if !connected {
                CybexWebSocketService.shared.connect()
            }
        }
    }
}
