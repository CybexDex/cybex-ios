//
//  PickerActions.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import HandyJSON
import RxCocoa

typealias PickerDidSelected = ((_ picker: UIPickerView) -> Void)

struct PickerContext: RouteContext, HandyJSON {
    var items: AnyObject?
    var selectedValue: (component: NSInteger, row: NSInteger) = (0, 0)
    var pickerDidSelected: PickerDidSelected?
}

struct PickerState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}
