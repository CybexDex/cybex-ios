//
//  ETODetailCoordinator.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol ETODetailCoordinatorProtocol {
    func openShare()
    func openETOCrowdVC()
    func openWebWithUrl(_ sender: String,type: CybexWebViewController.web_type)
}

protocol ETODetailStateManagerProtocol {
    var state: ETODetailState { get }
    
    func switchPageState(_ state:PageState)
    func fetchData()
    func fetchUpState()
    func checkInviteCode(code: String, callback:@escaping(Bool,String)->())
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
    
    func openWebWithUrl(_ sender: String,type: CybexWebViewController.web_type) {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            vc.vc_type = type
            vc.url = URL(string: sender)
            self.rootVC.pushViewController(vc ,animated: true)
        }
    }
}

extension ETODetailCoordinator: ETODetailStateManagerProtocol {
    
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
    
    func fetchData() {
        Broadcaster.notify(ETOStateManagerProtocol.self) { (coor) in
            if let model = coor.state.selectedProjectModel.value, let projectModel = model.projectModel {
                self.store.dispatch(SetProjectDetailAction(data: projectModel))
            }
            else {
                if let bannerModel = coor.state.selectedBannerModel.value, let bannerId = bannerModel.id.int {
                    ETOMGService.request(target: ETOMGAPI.getProjectDetail(id: bannerId), success: { json in
                        if let model = ETOProjectModel.deserialize(from: json.dictionaryObject) {
                            self.store.dispatch(SetProjectDetailAction(data: model))
                        }
                        self.switchPageState(PageState.normal(reason: .initialRefresh))
                    }, error: { (error) in
                        self.switchPageState(PageState.error(error: error, reason: .initialRefresh))
                    }, failure: { (error) in
                        self.switchPageState(PageState.error(error: error, reason: .initialRefresh))
                    })
                }
            }
        }
    }
    
    func fetchUserState() {
        if let name = UserManager.shared.name.value, let data = self.state.data.value, let projectModel = data.projectModel, let projectId = projectModel.project.int {
            
            ETOMGService.request(target: ETOMGAPI.checkUserState(name: name, id: projectId), success: { (json) in
                if let data = json.dictionaryObject, let model = ETOUserAuditModel.deserialize(from: data){
               
                    self.store.dispatch(FetchUserStateAction(data:model))
                }
                self.switchPageState(PageState.normal(reason: .initialRefresh))
            }, error: { (error) in
            }) { (error) in
            }
        }
        else {
            if let data = self.state.data.value, let projectModel = data.projectModel ,let projectState = projectModel.status{
                if projectState == .finish {
                    ETOManager.shared.changeState([.notLogin, .finished])
                }
                else if projectState == .pre {
                    ETOManager.shared.changeState([.notLogin, .notStarted])
                }
                else if projectState == .ok {
                    ETOManager.shared.changeState([.notLogin, .underway])
                }
                if let vc = self.rootVC.topViewController as? ETODetailViewController {
                    vc.contentView.getJoinButtonState()
                }
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
            if state.kyc_status == .not_start {
                etoState.insert(.KYCNotPassed)
                ETOManager.shared.changeState(etoState)
                if let vc = self.rootVC.topViewController as? ETODetailViewController {
                    vc.contentView.getJoinButtonState()
                }
                return
            }
            else if state.kyc_status == .ok {
                etoState.insert(.KYCPassed)
                if state.status == .unstart {
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
                
                if state.status == .waiting {
                    etoState.insert(.waitAudit)
                }
                else if state.status == .ok {
                    etoState.insert(.auditPassed)
                }
                else if state.status == .reject {
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
        let stateBefore = ETOManager.shared.getClauseState()
        let btnBefore = ETOManager.shared.getETOJoinButtonState()
        ETOManager.shared.changeState(etoState)
        let stateEnd = ETOManager.shared.getClauseState()
        let btnEnd = ETOManager.shared.getETOJoinButtonState()
        
        if (stateBefore != stateEnd || btnBefore != btnEnd), let vc = self.rootVC.topViewController as? ETODetailViewController {
            vc.contentView.getJoinButtonState()
        }
    }
    
    func checkInviteCode(code: String, callback:@escaping(Bool,String)->()) {
        guard let name = UserManager.shared.name.value, let projectModel = self.state.data.value?.projectModel else {
            callback(false,"")
            return
        }
        
        ETOMGService.request(target: ETOMGAPI.validCode(name: name, pid: projectModel.id, code: code), success: { json in
            callback(true,"")
        }, error: { error in
            callback(false,error.localizedDescription)
        }) { error in
            callback(false,error.localizedDescription)
        }
    }
    
    func updateETOProjectDetailAction() {
        guard let model = self.state.data.value, let projectModel = model.projectModel else { return }        
        ETOMGService.request(target: ETOMGAPI.refreshProject(id: projectModel.id), success: { json in
            if let dataJson = json.dictionaryObject, let refreshModel = ETOShortProjectStatusModel.deserialize(from: dataJson) {
                projectModel.finish_at = refreshModel.finish_at
                projectModel.status = refreshModel.status
                model.current_percent.accept((refreshModel.current_percent * 100).string(digits:2, roundingMode: .down) + "%")
                model.progress.accept(refreshModel.current_percent)
                model.status.accept(refreshModel.status!.description())
                model.project_state.accept(refreshModel.status)
                
                if refreshModel.status! == .pre {
                    model.detail_time.accept(timeHandle(projectModel.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                }
                else if refreshModel.status! == .ok {
                    model.detail_time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                }
                else if refreshModel.status! == .finish {
                    if refreshModel.finish_at != nil {
                        if projectModel.t_total_time == "" {
                            model.detail_time.accept(timeHandle(refreshModel.finish_at!.timeIntervalSince1970 - projectModel.start_at!.timeIntervalSince1970, isHiddenSecond: false))
                        }
                        else {
                            model.detail_time.accept(timeHandle(Double(projectModel.t_total_time)!, isHiddenSecond: false))
                        }
                    }
                }
            }
            self.switchPageState(PageState.normal(reason: .initialRefresh))
        }, error: { (error) in
        }) { error in
        }
//        }
        
//        if projectModel.status! == .pre {
//            model.detail_time.accept(timeHandle(projectModel.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
//        }
//        else if projectModel.status! == .ok {
//            model.detail_time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
//        }
//        else if projectModel.status! == .finish {
//            if projectModel.finish_at != nil {
//                if projectModel.t_total_time == "" {
//                    model.detail_time.accept(timeHandle(projectModel.finish_at!.timeIntervalSince1970 - projectModel.start_at!.timeIntervalSince1970, isHiddenSecond: false))
//                }
//                else {
//                    model.detail_time.accept(timeHandle(Double(projectModel.t_total_time)!, isHiddenSecond: false))
//                }
//            }
//        }
    }
}
