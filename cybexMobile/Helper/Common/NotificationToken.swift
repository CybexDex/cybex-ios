//
//  NotificationToken.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

/// Wraps normal `Notification` observing method, to provide a behavior of releasing `token` automatically when
/// observer gets deinit.
class NotificationToken {
    let token: NSObjectProtocol
    let center: NotificationCenter

    init(token: NSObjectProtocol, in center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {
    func addCustomObserver(forName name: Notification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Swift.Void) -> NotificationToken
    {
        let token: NSObjectProtocol = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(token: token, in: self)
    }

}
