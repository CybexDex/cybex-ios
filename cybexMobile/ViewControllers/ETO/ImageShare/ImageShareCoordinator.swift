//
//  ImageShareCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol ImageShareCoordinatorProtocol {
}

protocol ImageShareStateManagerProtocol {
    var state: ImageShareState { get }
}

class ImageShareCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ImageShareReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ImageShareState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ImageShareCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ImageShareStateManagerProtocol.self, observer: self)
    }
}

extension ImageShareCoordinator: ImageShareCoordinatorProtocol {
    
}

extension ImageShareCoordinator: ImageShareStateManagerProtocol {
    
}
