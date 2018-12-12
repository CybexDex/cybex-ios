//
//  Helpers.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

typealias CommonCallback = () -> Void
typealias CommonAnyCallback = (Any) -> Void

struct Log {
    static func assertionFailure(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
        Swift.assertionFailure("[Log] \(message())", file: file, line: line)
    }

    static func fatalError(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Never {
        Swift.fatalError("[Log] \(message())", file: file, line: line)
    }

    static func print(_ items: Any...) {
        let s = items.reduce("") { result, next in
            return result + String(describing: next)
        }
        Swift.print("[Log] \(s)")
    }
}

enum CybexNotificationKey {}

func guardSharedProperty<T>(_ input: T?) -> T {
    guard let shared = input else {
        Log.fatalError("Use \(T.self) before setup. ")
    }
    return shared
}

protocol ObjectDescriptable {
    func propertyDescription() -> String
}

extension ObjectDescriptable {
    func propertyDescription() -> String {
        let strings = Mirror(reflecting: self).children.flatMap { "\($0.label!): \($0.value)" }
        var string = ""
        for str in strings {
            string += String(str) + "\n"
        }
        return string
    }
}

struct WeakObject<T: AnyObject>: Equatable, Hashable {
    static func == (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
        return lhs.object === rhs.object
    }

    weak var object: T?
    init(_ object: T) {
        self.object = object
    }

    var hashValue: Int {
        if let object = self.object { return ObjectIdentifier(object).hashValue } else { return 0 }
    }
}
