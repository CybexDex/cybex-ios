//
//  CashHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

//充值提现
class CashHelper {
    class func checkMaxLength(_ sender: String, maxLength: Int) -> String {
        if sender.contains(".") {
            let stringArray = sender.components(separatedBy: ".")
            if let last = stringArray.last, last.count > maxLength, let first = stringArray.first, let maxLast = last.substring(from: 0, length: maxLength) {
                return first + "." + maxLast
            }
        }
        return sender
    }

}
