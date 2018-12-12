//
//  Utils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

func checkMaxLength(_ sender: String, maxLength: Int) -> String {
    if sender.contains(".") {
        let stringArray = sender.components(separatedBy: ".")
        if let last = stringArray.last, last.count > maxLength, let first = stringArray.first, let maxLast = last.substring(from: 0, length: maxLength) {
            return first + "." + maxLast
        }
    }
    return sender
}

func addressOf(_ pointer: UnsafeRawPointer) -> Int {
    return Int(bitPattern: pointer)
}

func addressOf<T: AnyObject>(_ point: T) -> Int {
    return unsafeBitCast(point, to: Int.self)
}

func getTimeZone() -> TimeInterval {
    let timeZone = TimeZone.current
    return TimeInterval(timeZone.secondsFromGMT(for: Date()))
}

func labelBaselineOffset(_ lineHeight: CGFloat, fontHeight: CGFloat) -> Float {
    return ((lineHeight - lineHeight) / 4.0).float
}
