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
    func openWebWithUrl(_ sender: String)
}

protocol ETODetailStateManagerProtocol {
    var state: ETODetailState { get }
    
    func switchPageState(_ state:PageState)
    func setETOProjectDetailModel(_ model: ETOProjectModel)
    func fetchData()
    func fetchUpState()
    func checkInviteCode(code: String, callback:@escaping(Bool)->())
    func updateETOProjectDetailAction()
    func fetchUserState()
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
    
    func openWebWithUrl(_ sender: String) {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            vc.vc_type = .whitelist
            vc.url = URL(string: sender)
            self.rootVC.pushViewController(vc ,animated: true)
        }
    }
}

extension ETODetailCoordinator: ETODetailStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
    
    func setETOProjectDetailModel(_ model: ETOProjectModel) {
        self.store.dispatch(SetProjectDetailAction(data: model))
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
        guard  let model = self.state.data.value?.projectModel, let projectState = model.status, let state = self.state.userState.value else { return }
        var etoState: ETOStateOption = .unset
        etoState.remove(.unset)
        if !UserManager.shared.isLoginIn {
            etoState.insert(.notLogin)
        }
        else {
            etoState.insert(.login)
            
            if state.kyc_result == "not_start" {
                etoState.insert(.KYCNotPassed)
                ETOManager.shared.changeState(etoState)
                return
            }
            else if state.kyc_result == "ok" {
                etoState.insert(.KYCPassed)
                if state.status == "unstart" {
                    etoState.insert(.notReserved)
                }
                else {
                    etoState.insert(.reserved)
                }
                
                if model.is_user_in == "0" {
                    etoState.insert(.notBookable)
                }
                else {
                    etoState.insert(.bookable)
                }
                
                if state.status == "waiting" {
                    etoState.insert(.waitAudit)
                }
                else if state.status == "ok" {
                    etoState.insert(.auditPassed)
                }
                else if state.status == "reject" {
                    etoState.insert(.auditNotPassed)
                }
            }
        }
        
        if projectState == .finish {
            etoState.insert(.finished)
        }
        else if projectState == .pre {
            etoState.insert(.notStarted)
        }
        else if projectState == .ok {
            etoState.insert(.underway)
        }
        ETOManager.shared.changeState(etoState)
    }
    
    func checkInviteCode(code: String, callback:@escaping(Bool)->()) {
        guard let name = UserManager.shared.name.value, let projectModel = self.state.data.value?.projectModel else {
            callback(false)
            return
        }
        
        ETOMGService.request(target: ETOMGAPI.validCode(name: name, pid: projectModel.id, code: code), success: { json in
            callback(true)
        }, error: { error in
            callback(false)
        }) { error in
            callback(false)
        }
    }
    
    func updateETOProjectDetailAction() {
        guard  let model = self.state.data.value?.projectModel else { return }
        ETOMGService.request(target: ETOMGAPI.refreshProject(id: model.id), success: { json in
            if let dataJson = json.dictionaryObject, let refreshModel = ETOShortProjectStatusModel.deserialize(from: dataJson) {
                self.store.dispatch(RefrehProjectModelAction(data: refreshModel))
            }
        }, error: { (error) in
            
        }) { error in
            
        }
    }
}
