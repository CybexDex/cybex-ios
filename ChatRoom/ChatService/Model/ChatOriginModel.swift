//
//  ChatOriginModel.swift
//  ChatRoom
//
//  Created by koofrank on 2018/11/16.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ChatMessage: NBLModel {
    var userName: String = ""
    var message: String = ""
    var deviceID: String = ""
    var msgID: Int = 0
    var timestamp: String = ""
    var signed: Bool = false

    public init() {

    }

    mutating public func mapping(_ json: JSON) {

    }
}
