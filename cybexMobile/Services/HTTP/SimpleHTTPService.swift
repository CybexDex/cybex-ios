//
//  SimpleNetwork.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import AwaitKit
import SwiftyJSON
import PromiseKit
import Alamofire
import Localize_Swift

enum SimpleHttpError: Error {
    case notExistData
}

struct Await {
    struct Queue {
        static let await = DispatchQueue(label: "com.nbltrsut.awaitqueue", attributes: .concurrent)
        static let async = DispatchQueue(label: "com.nbltrsut.asyncqueue", attributes: .concurrent)
        static let serialAsync = DispatchQueue(label: "com.nbltrsut.asyncqueue.serial")
    }
}

@discardableResult
func await<T>(_ promise: Promise<T>) throws -> T {
    return try Await.Queue.await.ak.await(promise)
}

@discardableResult
func await<T>(_ body: @escaping () throws -> T) throws -> T {
    return try Await.Queue.await.ak.await(body)
}

func async<T>(_ body: @escaping () throws -> T) -> Promise<T> {
    return Await.Queue.async.async(.promise, execute: body)
}

func async(_ body: @escaping () throws -> Void) {
    Await.Queue.async.ak.async(body)
}

func await(_ body: @escaping () throws -> Void) {
    Await.Queue.await.ak.async(body)
}

func serialAsync(_ body: @escaping () throws -> Void) {
    Await.Queue.serialAsync.ak.async(body)
}

func main(_ body: @escaping @convention(block) () -> Swift.Void) {
    DispatchQueue.main.async(execute: body)
}
