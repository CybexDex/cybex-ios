//
//  AccountActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya
import RxSwift
import RxCocoa

// MARK: - State
struct AccountState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)

    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}

struct AccountViewModel {
  var leftImage: UIImage?
  var name: String = ""
}
