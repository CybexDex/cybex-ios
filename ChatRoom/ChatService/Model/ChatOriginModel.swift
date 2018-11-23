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
    
    public var userName: String = ""
    public var message: String = ""
    public var deviceID: String = ""
    public var msgID: Int = 0
    public var timestamp: String = ""
    public var signed: Bool = false

    public init() {

    }

    mutating public func mapping(_ json: JSON) {

    }
}
