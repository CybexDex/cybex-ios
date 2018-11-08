//
//  ChatUser.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import ChatRoom

struct ChatUser: MSGUser {
    var displayName: String

    var avatar: UIImage?

    var avatarUrl: URL?

    var isSender: Bool
}
