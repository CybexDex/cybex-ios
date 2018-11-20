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
}

class PickerCoordinator: PickerRootCoordinator {
  var pickerDidSelected: PickerDidSelected?

    var store = Store<PickerState>(
        reducer: pickerReducer,
        state: nil,
        middleware: [trackingMiddleware]
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
}
