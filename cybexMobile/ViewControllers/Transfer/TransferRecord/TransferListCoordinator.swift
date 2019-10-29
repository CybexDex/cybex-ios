//
//  TransferListCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import PromiseKit

protocol TransferListCoordinatorProtocol {

    func openTransferDetail(_ sender: TransferRecordViewModel)
}

protocol TransferListStateManagerProtocol {
    var state: TransferListState { get }

    func fetchTransferRecords(_ page: Int, callback: ((Bool) -> Void)?)
}

class TransferListCoordinator: NavCoordinator {
    var store = Store<TransferListState>(
        reducer: transferListReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension TransferListCoordinator: TransferListCoordinatorProtocol {
    func openTransferDetail(_ sender: TransferRecordViewModel) {
        if let vc = R.storyboard.recode.transferDetailViewController() {
            vc.coordinator = TransferDetailCoordinator(rootVC: self.rootVC)
            vc.data  = sender
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension TransferListCoordinator: TransferListStateManagerProtocol {
    var state: TransferListState {
        return store.state
    }

    func fetchTransferRecords(_ page: Int, callback: ((Bool) -> Void)?) {
        guard let uid = UserManager.shared.getCachedAccount()?.id else { return }
        AccountHistoryService.request(target: .getTransferRecord(userId: uid, page: page), success: { (json) in
            let times = json.arrayValue.map({ $0["timestamp"].stringValue })

            if let model = [TransferRecord].deserialize(from: json.arrayValue.compactMap { $0["op"][1].dictionaryObject }) as? [TransferRecord] {
                var vmData: [(TransferRecord, time: String)] = []
                for (i, v) in model.enumerated() {
                    vmData.append((v, times[i]))
                }

                self.store.dispatch(ReduceTansferRecordsAction(data: vmData))
                callback?(model.count != 20)
            }

        }, error: { (error) in

        }) { (error) in

        }
    }
}
