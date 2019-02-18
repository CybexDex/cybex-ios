//
//  RecordChooseCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import SwiftyJSON
import cybex_ios_core_cpp

protocol RecordChooseCoordinatorProtocol {
}

protocol RecordChooseStateManagerProtocol {
    var state: RecordChooseState { get }
    
    func switchPageState(_ state: PageState)
    
    func fetchData(_ type: Int, maxCount: Int, count: Int)
}

class RecordChooseCoordinator: NavCoordinator {
    var store = Store(
        reducer: recordChooseReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
    
    var state: RecordChooseState {
        return store.state
    }
    
    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.comprehensive.recordChooseViewController()!
        let coordinator = RecordChooseCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }
    
    override func register() {
        Broadcaster.register(RecordChooseCoordinatorProtocol.self, observer: self)
        Broadcaster.register(RecordChooseStateManagerProtocol.self, observer: self)
    }
}

extension RecordChooseCoordinator: RecordChooseCoordinatorProtocol {
    
}

extension RecordChooseCoordinator: RecordChooseStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
    
    func fetchData(_ type: Int, maxCount: Int, count: Int) {
        switch type {
        case RecordChooseType.asset.rawValue:
            let accountName = UserManager.shared.name.value ?? ""

            GatewayQueryService.request(target: .login(accountName: accountName), success: { (_) in
                GatewayQueryService.request(target: .assetKinds(accountName: accountName), success: { (json) in
                    if let data = AccountAssets.deserialize(from: json.dictionaryObject) {
                        self.store.dispatch(FetchAccountAssetAction(data: data))
                    }
                }, error: { (_) in

                }) { (_) in

                }
            }, error: { (_) in

            }) { (_) in

            }

        case RecordChooseType.foudType.rawValue:
            
            self.store.dispatch(FetchDataAction(data: [R.string.localizable.openedAll.key.localized(),
                                                       R.string.localizable.recharge_deposit.key.localized(),
                                                       R.string.localizable.recharge_withdraw.key.localized()]))
        case RecordChooseType.time.rawValue:
            self.store.dispatch(FetchDataAction(data: ["5m",
                                                       "1h",
                                                       "1d"]))
        case RecordChooseType.kind.rawValue:
            self.store.dispatch(FetchDataAction(data: ["MA",
                                                       "EMA",
                                                       "MACD",
                                                       "BOLL"]))
        case RecordChooseType.orderbook.rawValue:
            var data: [String] = []
            for index in 0..<count {
                data.insert(R.string.localizable.trade_decimal_number.key.localizedFormat(maxCount - index), at: 0)
            }
            
            self.store.dispatch(FetchDataAction(data: data))
        case RecordChooseType.vesting.rawValue:
            self.store.dispatch(FetchDataAction(data: [R.string.localizable.vesting_time_unit_second.key.localized(),
                                                       R.string.localizable.vesting_time_unit_minute.key.localized(),
                                                       R.string.localizable.vesting_time_unit_hour.key.localized(),
                                                       R.string.localizable.vesting_time_unit_day.key.localized()]))
        default: break
        }
        
    }
}

