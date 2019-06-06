//
//  ETOCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol ETOCoordinatorProtocol {
    func openProjectHistroy()
}

protocol ETOStateManagerProtocol {
    var state: ETOState { get }

    func switchPageState(_ state: PageState)

    func fetchProjectData()

    func fetchBannersData()

    func setSelectedProjectData(_ model: ETOProjectViewModel)

    func setSelectedBannerData(_ model: ETOBannerModel)

    func refreshProjectDatas()

    func refreshTime()

    func resetBannersUrl()
}

class ETOCoordinator: NavCoordinator {
    var store = Store(
        reducer: ETOReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ETOState {
        return store.state
    }

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.main.etoViewController()!
        let coordinator = ETOCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(ETOCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOStateManagerProtocol.self, observer: self)
    }
}

extension ETOCoordinator: ETOCoordinatorProtocol {
    func openProjectItem() {
        if let vc = R.storyboard.etoDetail.etoDetailViewController() {
            vc.coordinator = ETODetailCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }

    func openProjectHistroy() {
        if let vc = R.storyboard.main.etoRecordListViewController() {
            vc.coordinator = ETORecordListCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension ETOCoordinator: ETOStateManagerProtocol {

    func switchPageState(_ state: PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }

    func fetchProjectData() {
        ETOMGService.request(target: ETOMGAPI.getProjects(offset: 0, limit: 4), success: { json in
            if let projects = json.arrayValue.map({ (data)  in
                ETOProjectModel.deserialize(from: data.dictionaryObject)
            }) as? [ETOProjectModel] {
                self.store.dispatch(FetchProjectModelAction(data: projects))
            }
        }, error: { (error) in
            self.switchPageState(PageState.error(error: error, reason: .initialRefresh))
        }) { (error) in
            self.switchPageState(PageState.error(error: error, reason: .initialRefresh))
        }
    }

    func fetchBannersData() {
        ETOMGService.request(target: ETOMGAPI.getBanner, success: { (json) in
            if let banners = json.arrayValue.map({ data in
                ETOBannerModel.deserialize(from: data.dictionaryObject)
            }) as? [ETOBannerModel] {
                self.store.dispatch(FetchBannerModelAction(data: banners))
            }
        }, error: { (error) in
            self.switchPageState(PageState.error(error: error, reason: .initialRefresh))
        }) { (error) in
            self.switchPageState(PageState.error(error: error, reason: .initialRefresh))
        }
    }

    func setSelectedProjectData(_ model: ETOProjectViewModel) {
        self.store.dispatch(SetSelectedProjectModelAction(data: model))
        self.openProjectItem()
    }

    func setSelectedBannerData(_ model: ETOBannerModel) {
        self.store.dispatch(SetSelectedBannerModelAction(data: model))
        if let projectModels = self.state.data.value {
            for projectModel in projectModels {
                if let data = projectModel.projectModel, let id = model.id {
                    if data.project == id {
                        self.setSelectedProjectData(projectModel)
                        return
                    }
                }
            }
        }
        self.openProjectItem()
    }

    func refreshProjectDatas() {
        if let projectModels = self.state.data.value {
            for viewModel in projectModels {
                if let projectModel = viewModel.projectModel,let project = projectModel.project.components(separatedBy: ".").last, let projectId = project.int {
                    ETOMGService.request(target: ETOMGAPI.refreshProject(id: projectId), success: { (json) in
                        if let dataJson = json.dictionaryObject, let refreshModel = ETOShortProjectStatusModel.deserialize(from: dataJson) {
                            projectModel.status = refreshModel.status
                            projectModel.finishAt = refreshModel.finishAt
                            if refreshModel.currentPercent <= 1 {
                                viewModel.currentPercent.accept((refreshModel.currentPercent * 100).formatCurrency(digitNum: AppConfiguration.percentPrecision) + "%")
                                viewModel.progress.accept(refreshModel.currentPercent)
                            }
                            else {
                                viewModel.currentPercent.accept(100.formatCurrency(digitNum: AppConfiguration.percentPrecision) + "%")
                                viewModel.progress.accept(1)
                            }
                            viewModel.status.accept(refreshModel.status!.description())
                            viewModel.projectState.accept(refreshModel.status)
                            
                            if let status = refreshModel.status {
                                if status == .pre {
                                    if let startAt = projectModel.startAt {
                                        viewModel.time.accept(timeHandle(startAt.timeIntervalSince1970 - Date().timeIntervalSince1970))
                                    }
                                } else if status == .ok {
                                    if let endAt = projectModel.endAt {
                                        viewModel.time.accept(timeHandle(endAt.timeIntervalSince1970 - Date().timeIntervalSince1970))
                                    }
                                } else if status == .finish {
                                    /*
                                     if projectModel.tTotalTime == "" {
                                     if let finishAt = projectModel.finishAt, let startAt = projectModel.startAt{
                                     self.detailTime.accept(timeHandle(finishAt.timeIntervalSince1970 - startAt.timeIntervalSince1970, isHiddenSecond: false))
                                     
                                     self.time.accept(timeHandle(finishAt.timeIntervalSince1970 - startAt.timeIntervalSince1970, isHiddenSecond: false))
                                     }
                                     else{
                                     self.detailTime.accept("")
                                     self.time.accept("")
                                     
                                     }
                                     } else {
                                     if let tTotalTimeDouble = projectModel.tTotalTime.double() {
                                     self.detailTime.accept(timeHandle(tTotalTimeDouble, isHiddenSecond: false))
                                     self.time.accept(timeHandle(tTotalTimeDouble, isHiddenSecond: false))
                                     }
                                     }
                                     */
                                    
                                    
                                    
                                    if refreshModel.finishAt != nil {
                                        if projectModel.tTotalTime == "" {
                                            if let finishAt = refreshModel.finishAt, let startAt = projectModel.startAt {
                                                viewModel.time.accept(timeHandle(finishAt.timeIntervalSince1970 - startAt.timeIntervalSince1970, isHiddenSecond: false))
                                            }
                                            else {
                                                viewModel.time.accept("")
                                            }
                                        } else {
                                            if let tTotalTimeDouble = Double(projectModel.tTotalTime) {
                                                viewModel.time.accept(timeHandle(tTotalTimeDouble, isHiddenSecond: false))
                                            }else {
                                                if let finishAt = refreshModel.finishAt, let startAt = projectModel.startAt {
                                                    viewModel.time.accept(timeHandle(finishAt.timeIntervalSince1970 - startAt.timeIntervalSince1970, isHiddenSecond: false))
                                                }
                                                else {
                                                    viewModel.time.accept("")
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        if projectModel.tTotalTime == "" {
                                            viewModel.time.accept("")
                                        }
                                        else {
                                            if let tTotalTimeDouble = Double(projectModel.tTotalTime) {
                                                viewModel.time.accept(timeHandle(tTotalTimeDouble, isHiddenSecond: false))
                                            }else {
                                                viewModel.time.accept("")
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }, error: { (_) in
                    }) { (_) in
                    }
                }
            }
        }
    }

    func resetBannersUrl() {
        if let models = state.banners.value {
            self.store.dispatch(ResetBannerUrlsAction(data: models))
        }
    }

    func refreshTime() {
//        if let projectModels = self.state.data.value {
//            for viewModel in projectModels {
//                if let projectModel = viewModel.projectModel {
//                    if projectModel.status! == .pre {
//                        viewModel.time.accept(timeHandle(projectModel.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
//                    }
//                    else if projectModel.status! == .ok {
//                        viewModel.time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
//                    }
//                    else if projectModel.status! == .finish {
//                        if projectModel.finish_at != nil {
//                            if projectModel.t_total_time == "" {
//                                viewModel.time.accept(timeHandle(projectModel.finish_at!.timeIntervalSince1970 - projectModel.start_at!.timeIntervalSince1970,isHiddenSecond: false))
//                            }
//                            else {
//                                viewModel.time.accept(timeHandle(Double(projectModel.t_total_time)!, isHiddenSecond: false))
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}
