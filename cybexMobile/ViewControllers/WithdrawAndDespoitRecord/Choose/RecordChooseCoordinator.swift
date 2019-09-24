//
//  RecordChooseCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift

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

            guard let setting = AppConfiguration.shared.enableSetting.value else {
                return
            }

            let gateway2 = setting.gateWay2
            if gateway2 {
                Gateway2Service.request(target: .assetsOfTransactions(userName: accountName), success: { (json) in
                    let records =  json["records"].arrayValue.map({ (record) -> AccountAssetModel in
                        let model = AccountAssetModel(count: record["total"].intValue, groupInfo: GroupInfo(asset: record["asset"].stringValue, fundType: ""))
                        return model
                    })
                    let assets = AccountAssets(total: json["total"].intValue, offset: 0, size: 0, records: records)
                    self.store.dispatch(FetchAccountAssetAction(data: assets))
                }, error: { (_) in

                }) { (_) in

                }
                return
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
        case RecordChooseType.tradeShowType.rawValue:
            self.store.dispatch(FetchDataAction(data: [R.string.localizable.orderbook_show_type_1.key.localized(),
                                                       R.string.localizable.orderbook_show_type_2.key.localized(),
                                                       R.string.localizable.orderbook_show_type_3.key.localized()]))
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

