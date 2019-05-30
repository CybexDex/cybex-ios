//
//  ETORecordListCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol ETORecordListCoordinatorProtocol {
}

protocol ETORecordListStateManagerProtocol {
    var state: ETORecordListState { get }

    func fetchETORecord(_ page: Int, reason: PageLoadReason)
    func switchPageState(_ state: PageState)
}

class ETORecordListCoordinator: NavCoordinator {
    var store = Store(
        reducer: ETORecordListReducer,
        state: nil,
        middleware: [trackingMiddleware]
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
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }

    func fetchETORecord(_ page: Int, reason: PageLoadReason) {
        guard let name = UserManager.shared.name.value else { return }
        ETOMGService.request(target: .getUserTradeList(name: name, page: page, limit: 20), success: { (json) in
            self.store.dispatch(ETONextPageAction(page: page))

            let data = json
            if data.arrayValue.count == 0 && reason != .manualLoadMore {
                self.switchPageState(.noData)
            } else if data.arrayValue.count < 20 {
                self.switchPageState(.noMore)
            } else {
                self.switchPageState(.normal(reason: reason))
            }

            let add = reason == .manualLoadMore

            self.store.dispatch(ETORecordListFetchedAction(data: data, add: add))
        }, error: { (error) in
            self.store.dispatch(ETONextPageAction(page: page))
            self.switchPageState(PageState.error(error: error, reason: reason))
        }) { (error) in
            self.store.dispatch(ETONextPageAction(page: page))
            self.switchPageState(PageState.error(error: error, reason: reason))
        }
    }
}
