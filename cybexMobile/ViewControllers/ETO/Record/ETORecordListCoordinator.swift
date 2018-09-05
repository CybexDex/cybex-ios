//
//  ETORecordListCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter
import Async

protocol ETORecordListCoordinatorProtocol {
}

protocol ETORecordListStateManagerProtocol {
    var state: ETORecordListState { get }
    
    func fetchETORecord(_ page: Int, reason: PageLoadReason)
    func switchPageState(_ state:PageState)
}

class ETORecordListCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETORecordListReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETORecordListState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETORecordListCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETORecordListStateManagerProtocol.self, observer: self)
    }
}

extension ETORecordListCoordinator: ETORecordListCoordinatorProtocol {
    
}

extension ETORecordListCoordinator: ETORecordListStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        Async.main {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
    
    func fetchETORecord(_ page: Int, reason: PageLoadReason) {
        guard let name = UserManager.shared.name.value else { return }
        ETOMGService.request(target: .getUserTradeList(name: name, page: page, limit: 20), success: { (json) in
            if json.arrayValue.count == 0 && reason != .manualLoadMore {
                self.switchPageState(.noData)
            }
            else if json.arrayValue.count < 20 {
                self.switchPageState(.noMore)
            }
            else {
                self.switchPageState(.normal(reason: reason))
            }
            
            self.store.dispatch(ETORecordListFetchedAction(data: json))

        }, error: { (error) in
            self.switchPageState(PageState.error(error: error, reason: reason))
        }) { (error) in
            self.switchPageState(PageState.error(error: error, reason: reason))
        }
    }
}
