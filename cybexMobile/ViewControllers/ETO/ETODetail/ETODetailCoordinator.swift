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
    func openWebWithUrl(_ sender: String, type: CybexWebViewController.WebType)
}

protocol ETODetailStateManagerProtocol {
    var state: ETODetailState { get }

    func switchPageState(_ state: PageState)
    func fetchData()
    func fetchUpState()
    func checkInviteCode(code: String, callback:@escaping(Bool, String) -> Void)
    func updateETOProjectDetailAction()
    func fetchUserState()
}

class ETODetailCoordinator: NavCoordinator {
    var store = Store(
        reducer: ETODetailReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ETODetailState {
        return store.state
    }

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        if let vc = R.storyboard.etoDetail.etoDetailViewController(){
            let coordinator = ETODetailCoordinator(rootVC: root)
            vc.coordinator = coordinator
            coordinator.store.dispatch(RouteContextAction(context: context))
            return vc
        }
        else {
            return BaseViewController()
        }
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
        if let vc = R.storyboard.etO.etoCrowdViewController(){
            let coor = ETOCrowdCoordinator(rootVC: self.rootVC)
            vc.coordinator = coor
            self.rootVC.pushViewController(vc)
        }
    }

    func openWebWithUrl(_ sender: String, type: CybexWebViewController.WebType) {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            vc.vcType = type
            vc.url = URL(string: sender)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension ETODetailCoordinator: ETODetailStateManagerProtocol {

    func switchPageState(_ state: PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }

    func fetchData() {
        var isFetchCoor = false
        Broadcaster.notify(ETOStateManagerProtocol.self) { (coor) in
            isFetchCoor = true
            if let model = coor.state.selectedProjectModel.value, let projectModel = model.projectModel {
                self.store.dispatch(SetProjectDetailAction(data: projectModel))
            } else {
                if let bannerModel = coor.state.selectedBannerModel.value, let bannerId = bannerModel.id, let id = bannerId.int {
                    fetchProjectModelWithId(id)
                } else {

                }
            }
        }
        if isFetchCoor == false {
            if let context = self.state.context.value as? ETODetailContext {
                fetchProjectModelWithId(context.pid)
            }
        }
    }

    func fetchProjectModelWithId(_ id: Int) {
        ETOMGService.request(target: ETOMGAPI.getProjectDetail(id: id), success: { json in
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

    func fetchUserState() {
        if let name = UserManager.shared.name.value,
            let data = self.state.data.value,
            let projectModel = data.projectModel,
            let projectId = projectModel.project.components(separatedBy: ".").last?.int {
            ETOMGService.request(target: ETOMGAPI.checkUserState(name: name, id: projectId), success: { (json) in
                if let data = json.dictionaryObject, let model = ETOUserAuditModel.deserialize(from: data) {

                    self.store.dispatch(FetchUserStateAction(data: model))
                }
                self.switchPageState(PageState.normal(reason: .initialRefresh))
            }, error: { (_) in
            }) { (_) in
            }
        } else {
            if let data = self.state.data.value, let projectModel = data.projectModel, let projectState = projectModel.status {
                if projectState == .finish {
                    ETOManager.shared.changeState([.notLogin, .finished])
                } else if projectState == .pre {
                    ETOManager.shared.changeState([.notLogin, .notStarted])
                } else if projectState == .ok {
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
        if !UserManager.shared.logined {
            etoState.insert(.notLogin)
        } else {
            etoState.insert(.login)
//            if state.kycStatus == .notStart {
//                ETOManager.shared.changeState(etoState)
//                if let vc = self.rootVC.topViewController as? ETODetailViewController {
//                    vc.contentView.getJoinButtonState()
//                }
//                return
//            } else if state.kycStatus == .ok {
                if state.status == .unstart {
                    etoState.insert(.notReserved)
                } else {
                    etoState.insert(.reserved)
                }
//            }
        }
        if projectState == .finish {
            etoState.insert(.finished)
        } else if projectState == .pre {
            etoState.insert(.notStarted)
        } else if projectState == .ok {
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

    func checkInviteCode(code: String, callback:@escaping(Bool, String) -> Void) {
        guard let name = UserManager.shared.name.value, let projectModel = self.state.data.value?.projectModel else {
            callback(false, "")
            return
        }

        ETOMGService.request(target: ETOMGAPI.validCode(name: name, pid: projectModel.id, code: code), success: { _ in
            callback(true, "")
        }, error: { error in
            callback(false, error.localizedDescription)
        }) { error in
            callback(false, error.localizedDescription)
        }
    }

    func updateETOProjectDetailAction() {
        guard let model = self.state.data.value, let projectModel = model.projectModel, let project = projectModel.project.components(separatedBy: ".").last, let id = project.int else { return }
        ETOMGService.request(target: ETOMGAPI.refreshProject(id: id), success: { json in
            if let dataJson = json.dictionaryObject, let refreshModel = ETOShortProjectStatusModel.deserialize(from: dataJson) {
                projectModel.finishAt = refreshModel.finishAt
                projectModel.status = refreshModel.status
                model.currentPercent.accept((refreshModel.currentPercent * 100).formatCurrency(digitNum: AppConfiguration.percentPrecision) + "%")
                model.progress.accept(refreshModel.currentPercent)
                if let refreshStatus = refreshModel.status {
                    model.status.accept(refreshStatus.description())
                }
                model.projectState.accept(refreshModel.status)
                if let status = refreshModel.status {
                    if status == .pre, let startAt = projectModel.startAt{
                        model.detailTime.accept(timeHandle(startAt.timeIntervalSince1970 - Date().timeIntervalSince1970))
                    } else if status == .ok, let endAt = projectModel.endAt {
                        model.detailTime.accept(timeHandle(endAt.timeIntervalSince1970 - Date().timeIntervalSince1970))
                    } else if status == .finish {
                        if let finishAt = refreshModel.finishAt {
                            if projectModel.tTotalTime == "" {
                                model.detailTime.accept(timeHandle(finishAt.timeIntervalSince1970 - projectModel.startAt!.timeIntervalSince1970, isHiddenSecond: false))
                            } else {
                                if let tTotalTimeDouble = projectModel.tTotalTime.double() {
                                    model.detailTime.accept(timeHandle(tTotalTimeDouble, isHiddenSecond: false))
                                }
                            }
                        }
                    }
                }
            }
            self.switchPageState(PageState.normal(reason: .initialRefresh))
        }, error: { (_) in
        }) { _ in
        }
    }
}
