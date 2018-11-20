//
//  SettingDetailCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/2.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol SettingDetailCoordinatorProtocol {
  func popViewController(_ animated: Bool)
}

protocol SettingDetailStateManagerProtocol {
    var state: SettingDetailState { get }

}

class SettingDetailCoordinator: NavCoordinator {
    var store = Store<SettingDetailState>(
        reducer: gSettingDetailReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension SettingDetailCoordinator: SettingDetailCoordinatorProtocol {
  func popViewController(_ animated: Bool) {
    self.rootVC.popToRootViewController(animated: animated)

  }
}

extension SettingDetailCoordinator: SettingDetailStateManagerProtocol {
    var state: SettingDetailState {
        return store.state
    }
}
