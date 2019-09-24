//
//  LockupAssetsActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import RxCocoa
import RxSwift

// MARK: - State
struct LockupAssetsState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    
    var data: BehaviorRelay<LockUpAssetsVMData> = BehaviorRelay(value: LockUpAssetsVMData(datas: []))
    var ethPrice: Double = 0
}

struct FetchedLockupAssetsData: ReSwift.Action {
    let data: [LockUpAssetsMData]
}

struct LockUpAssetsVMData: Equatable {
    var datas: [LockupAssteData]
}
struct LockupAssteData: Equatable {
    static func == (lhs: LockupAssteData, rhs: LockupAssteData) -> Bool {
        return lhs.amount == rhs.amount &&
            lhs.name == rhs.name &&
            lhs.amount == rhs.amount &&
            lhs.RMBCount == rhs.RMBCount &&
            lhs.progress == rhs.progress &&
            lhs.endTime == rhs.endTime &&
            lhs.id == rhs.id &&
            lhs.balance == rhs.balance &&
            lhs.owner == rhs.owner
    }
    
    var icon: String = ""
    var name: String = ""
    var amount: String = ""
    var RMBCount: String = ""
    var progress: String = ""
    var endTime: String = ""
    var id: String = ""
    var balance: Asset?
    var owner: String = ""
}
