//
//  WithdrawAndDespoitRecordActions.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON

//MARK: - State
struct WithdrawAndDespoitRecordState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
struct WithdrawAndDespoitRecordFetchedAction: Action {
    var data:JSON
}
