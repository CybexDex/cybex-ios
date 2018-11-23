//
//  Utils.swift
//  ChatRoom
//
//  Created by koofrank on 2018/11/23.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

public class Delegate<Input, Output> {
    init() {}

    private var block: ((Input) -> Output?)?

    public func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) {
        // The `target` is weak inside block, so you do not need to worry about it in the caller side.
        self.block = { [weak target] input in
            guard let target = target else { return nil }
            return block?(target, input)
        }
    }

    func call(_ input: Input) -> Output? {
        return block?(input)
    }
}

extension Delegate where Input == Void {
    // To make syntax better for `Void` input.
    func call() -> Output? {
        return call(())
    }
}
