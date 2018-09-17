//
//  ETORecordListActions.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import DifferenceKit

//MARK: - State
struct ETORecordListState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data:BehaviorRelay<[ETOTradeHistoryModel]> = BehaviorRelay(value: [])
    var changeSet:BehaviorRelay<StagedChangeset<[ETOTradeHistoryModel]>> = BehaviorRelay(value: StagedChangeset<[ETOTradeHistoryModel]>())

    var page:BehaviorRelay<Int> = BehaviorRelay(value: 1)
}

//MARK: - Action

struct ETORecordListFetchedAction: Action {
    var data: JSON
    var add: Bool 
}

struct ETONextPageAction: Action {
    var page: Int
}

