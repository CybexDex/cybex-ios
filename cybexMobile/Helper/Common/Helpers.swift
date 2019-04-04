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
    //debug crash only
    static func assertionFailure(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line, flag: String = "Log") {
        Swift.assertionFailure("[\(flag)] \(message())", file: file, line: line)
    }

    //debug release crash
    static func fatalError(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line,  flag: String = "Log") -> Never {
        Swift.fatalError("[\(flag)] \(message())", file: file, line: line)
    }

    static func print(_ items: Any..., flag: String = "Log") {
        #if DEBUG

        let s = items.reduce("") { result, next in
            return result + String(describing: next)
        }
        Swift.print("[\(flag)] \(s)")

        #endif
    }

    static func fail(_ items: Any..., flag: String = "BusinessFail") {
        let s = items.reduce("") { result, next in
            return result + String(describing: next)
        }

        let output = "[\(flag)] \(s)"

        #if DEBUG

        Swift.print(output)

        #endif

        sendStatEvent(output)
    }
}

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

extension Range where Bound == String.Index {
    var nsRange: NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

