//
//  CallbackQueue.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

/// Callback queue behaviors when a closure call is dispatched.
///
/// - asyncMain: Dispatches a call to `DispatchQueue.main` with the `async` behavior.
/// - currentMainOrAsync: Dispatches a call to `DispatchQueue.main` with the `async` behavior if
///                       the current queue is not `.main`. Otherwise, calls a closure immediately in the main
///                       queue.
/// - untouch: Does not change a call queue for a closure.
/// - dispatch: Dispatches a call to a specified `DispatchQueue` object.
/// - operation: Uses a specified `OperationQueue` object and adds a closure to the operation queue.
public enum CallbackQueue {

    /// Dispatches a call to `DispatchQueue.main` with the `async` behavior.
    case asyncMain

    /// Dispatches a call to `DispatchQueue.main` with the `async` behavior if
    /// the current queue is not `.main`. Otherwise, calls a closure immediately in the main queue.
    case currentMainOrAsync

    /// Does not change a call queue for a closure.
    case untouch

    /// Dispatches a call to a specified `DispatchQueue` object.
    case dispatch(DispatchQueue)

    /// Uses a specified `OperationQueue` object and adds a closure to the operation queue.
    case operation(OperationQueue)

    func execute(_ block: @escaping () -> Void) {
        switch self {
        case .asyncMain:
            DispatchQueue.main.async { block() }
        case .currentMainOrAsync:
            DispatchQueue.main.safeAsync { block() }
        case .untouch:
            block()
        case .dispatch(let queue):
            queue.async { block() }
        case .operation(let queue):
            queue.addOperation { block() }
        }
    }
}

extension DispatchQueue {
    // This method will dispatch the `block` to self.
    // If `self` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
