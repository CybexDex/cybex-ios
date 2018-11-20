//
//  PickerCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol PickerCoordinatorProtocol {
    func finishWithPicker(_ picker: UIPickerView)
}

protocol PickerStateManagerProtocol {
    var state: PickerState { get }
}

class PickerCoordinator: NavCoordinator {
    var store = Store<PickerState>(
        reducer: pickerReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.components.pickerViewController()!
        let coordinator = PickerCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

}

extension PickerCoordinator: PickerCoordinatorProtocol {
    func finishWithPicker(_ picker: UIPickerView) {
        if let context = self.state.context.value as? PickerContext, let pickerSelect = context.pickerDidSelected {
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
