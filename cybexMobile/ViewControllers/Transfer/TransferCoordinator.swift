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
  func pushToRecordVC()
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
  func pushToRecordVC() {
    let recordVC = R.storyboard.recode.transferListViewController()
    let coordinator = TransferListCoordinator(rootVC: self.rootVC)
    recordVC?.coordinator = coordinator
    self.rootVC.pushViewController(recordVC!, animated: true)
  }

  func showPicker() {
    let width = ModalSize.full
    let height = ModalSize.custom(size: 244)
    let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 244))
    let customType = PresentationType.custom(width: width, height: height, center: center)
    
    let presenter = Presentr(presentationType: customType)
    presenter.dismissOnTap = true
    presenter.keyboardTranslationType = .moveUp
    
    let newVC = BaseNavigationController()
    let pickerCoordinator = PickerRootCoordinator(rootVC: newVC)
    self.rootVC.topViewController?.customPresentViewController(presenter, viewController: newVC, animated: true, completion: nil)
    pickerCoordinator.startWithItems(["CYB","ETH","BTC"] as AnyObject, selectedValue: (0, 0))
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
