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

class ETOCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )

    var state: ETOState {
        return store.state
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
        ETOMGService.request(target: ETOMGAPI.getBanner(), success: { (json) in
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
                if let data = projectModel.projectModel {
                    if data.project == model.id {
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
                if let projectModel = viewModel.projectModel {
                    ETOMGService.request(target: ETOMGAPI.refreshProject(id: projectModel.id), success: { (json) in
                        if let dataJson = json.dictionaryObject, let refreshModel = ETOShortProjectStatusModel.deserialize(from: dataJson) {
                            projectModel.status = refreshModel.status
                            projectModel.finishAt = refreshModel.finishAt
                            viewModel.currentPercent.accept((refreshModel.currentPercent * 100).string(digits: 2, roundingMode: .down) + "%")
                            viewModel.progress.accept(refreshModel.currentPercent)
                            viewModel.status.accept(refreshModel.status!.description())
                            viewModel.projectState.accept(refreshModel.status)

                            if refreshModel.status! == .pre {
                                viewModel.time.accept(timeHandle(projectModel.startAt!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                            } else if refreshModel.status! == .ok {
                                viewModel.time.accept(timeHandle(projectModel.endAt!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                            } else if refreshModel.status! == .finish {
                                if refreshModel.finishAt != nil {
                                    if projectModel.tTotalTime == "" {
                                        viewModel.time.accept(timeHandle(refreshModel.finishAt!.timeIntervalSince1970 - projectModel.startAt!.timeIntervalSince1970, isHiddenSecond: false))
                                    } else {
                                        viewModel.time.accept(timeHandle(Double(projectModel.tTotalTime)!, isHiddenSecond: false))
                                    }
                                }
                            }
                        }
                    }, error: { (error) in
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
