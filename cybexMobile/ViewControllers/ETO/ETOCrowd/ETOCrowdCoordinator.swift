//
//  ETOCrowdCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETOCrowdCoordinatorProtocol {
}

protocol ETOCrowdStateManagerProtocol {
    var state: ETOCrowdState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchData()
    func fetchUserRecord()
}

class ETOCrowdCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOCrowdReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETOCrowdState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETOCrowdCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOCrowdStateManagerProtocol.self, observer: self)
    }
}

extension ETOCrowdCoordinator: ETOCrowdCoordinatorProtocol {
    
}

extension ETOCrowdCoordinator: ETOCrowdStateManagerProtocol {
    func fetchData() {
        Broadcaster.notify(ETODetailStateManagerProtocol.self) {(coor) in
            self.store.dispatch(SetProjectDetailAction(data: coor.state.data.value!))
        }
    }
    
    func fetchUserRecord() {
        guard let name = UserManager.shared.name.value, let data = self.state.data.value else { return }

        ETOMGService.request(target: .refreshUserState(name: name, pid: data.id), success: { (json) in
            if let model = ETOUserModel.deserialize(from: json.dictionaryObject) {
                self.store.dispatch(fetchCurrentTokenCountAction(userModel: model))
            }
            
        }, error: { (error) in
            
        }) { (error) in
            
        }
    }
    
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
