//
//  ETOCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETOCoordinatorProtocol {
    func openProjectItem()
    func openETOCrowdVC()
}

protocol ETOStateManagerProtocol {
    var state: ETOState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchProjectData()
    
    func fetchBannersData()
}

class ETOCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETOState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETOCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOStateManagerProtocol.self, observer: self)
    }
}

extension ETOCoordinator: ETOCoordinatorProtocol {
    func openProjectItem() {
    }
        
    func openETOCrowdVC() {
        let vc = R.storyboard.etO.etoCrowdViewController()!
        let coor = ETOCrowdCoordinator(rootVC: self.rootVC)
        vc.coordinator = coor
        self.rootVC.pushViewController(vc)
    }
}

extension ETOCoordinator: ETOStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
    
    func fetchProjectData() {
        
    }
    
    func fetchBannersData() {
        
    }
}
