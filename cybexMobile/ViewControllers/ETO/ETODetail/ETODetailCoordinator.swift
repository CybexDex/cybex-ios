//
//  ETODetailCoordinator.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETODetailCoordinatorProtocol {
    func openShare()
    func openETOCrowdVC()
}

protocol ETODetailStateManagerProtocol {
    var state: ETODetailState { get }
    
    func switchPageState(_ state:PageState)
    
    func setETOProjectDetailModel(_ model: ETOProjectModel)
    
    func fetchData()
    
    func fetchUpState()
}

class ETODetailCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETODetailReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETODetailState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETODetailCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETODetailStateManagerProtocol.self, observer: self)
    }
    
    func fetchData() {
        Broadcaster.notify(ETOStateManagerProtocol.self) { (coor) in
            if let model = coor.state.selectedProjectModel.value {
                self.store.dispatch(SetProjectDetailAction(data: model))
            }
        }
    }
    
    func fetchUserState() {
        if let name = UserManager.shared.name.value, let data = self.state.data.value, let projectModel = data.projectModel, let projectId = projectModel.project.int {
            ETOMGService.request(target: ETOMGAPI.checkUserState(name: name, id: projectId), success: { (json) in
                if let data = json.dictionaryObject, let model = ETOUserAuditModel.deserialize(from: data){
                    self.store.dispatch(FetchUserStateAction(data:model))
                }
            }, error: { (error) in
                
            }) { (error) in
                
            }
        }
    }
    
    
    func fetchUpState() {
        if !UserManager.shared.isLoginIn {
            ETOManager.shared.changeState(.notLogin)
        }
        else {
            if let state = self.state.userState.value {
                if state.status == "unstart" {
                    ETOManager.shared.changeState([.login, .notBookable])
                }
            }
        }
    }
}

extension ETODetailCoordinator: ETODetailCoordinatorProtocol {
    func openShare() {
        if let vc = R.storyboard.main.imageShareViewController() {
            vc.coordinator = ImageShareCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
    
    func openETOCrowdVC() {
        let vc = R.storyboard.etO.etoCrowdViewController()!
        let coor = ETOCrowdCoordinator(rootVC: self.rootVC)
        vc.coordinator = coor
        self.rootVC.pushViewController(vc)
    }
}

extension ETODetailCoordinator: ETODetailStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
    
    func setETOProjectDetailModel(_ model: ETOProjectModel) {
        self.store.dispatch(SetProjectDetailAction(data: model))
    }
}
