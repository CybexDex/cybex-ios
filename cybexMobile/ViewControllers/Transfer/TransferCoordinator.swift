//
//  TransferCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Presentr

protocol TransferCoordinatorProtocol {
  func showPicker()
}

protocol TransferStateManagerProtocol {
    var state: TransferState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class TransferCoordinator: AccountRootCoordinator {
    
    lazy var creator = TransferPropertyActionCreate()
    
    var store = Store<TransferState>(
        reducer: TransferReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension TransferCoordinator: TransferCoordinatorProtocol {
  func showPicker() {
    let width = ModalSize.full
    let height = ModalSize.custom(size: 369)
    let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 369))
    let customType = PresentationType.custom(width: width, height: height, center: center)
    
    let presenter = Presentr(presentationType: customType)
    presenter.dismissOnTap = false
    presenter.keyboardTranslationType = .moveUp
    
    let newVC = BaseNavigationController()
    let pickerCoordinator = PickerRootCoordinator(rootVC: newVC)
    
    self.rootVC.topViewController?.customPresentViewController(presenter, viewController: newVC, animated: true, completion: nil)
        pickerCoordinator .start()
  }
}

extension TransferCoordinator: TransferStateManagerProtocol {
    var state: TransferState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
