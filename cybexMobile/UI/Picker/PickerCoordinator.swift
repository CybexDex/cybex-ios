//
//  PickerCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

typealias PickerDidSelected = ((_ picker: UIPickerView) -> Void)

protocol PickerCoordinatorProtocol {
  func finishWithPicker(_ picker: UIPickerView)
}

protocol PickerStateManagerProtocol {
    var state: PickerState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<PickerState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class PickerCoordinator: PickerRootCoordinator {

    lazy var creator = PickerPropertyActionCreate()

  var pickerDidSelected: PickerDidSelected?

    var store = Store<PickerState>(
        reducer: PickerReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )
}

extension PickerCoordinator: PickerCoordinatorProtocol {
  func finishWithPicker(_ picker: UIPickerView) {
    if let pickerSelect = self.pickerDidSelected {
      pickerSelect(picker)
    }
    self.rootVC.dismiss(animated: true, completion: nil)
  }
}

extension PickerCoordinator: PickerStateManagerProtocol {
    var state: PickerState {
        return store.state
    }

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<PickerState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

}
