//
//  ETOCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETOCoordinatorProtocol {
    func openProjectHistroy()
}

protocol ETOStateManagerProtocol {
    var state: ETOState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchProjectData()
    
    func fetchBannersData()
    
    func setSelectedProjectData(_ model: ETOProjectModel)
    
    func setSelectedBannerData(_ model: ETOBannerModel)
    
    func refreshProjectDatas()
    
    func refreshTime()
}

class ETOCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOReducer,
        state: nil,
        middleware:[TrackingMiddleware]
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
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
    
    func fetchProjectData() {
        ETOMGService.request(target: ETOMGAPI.getProjects(offset: 0, limit: 4), success: { json in
            if let projects = json.arrayValue.map({ (data)  in
                ETOProjectModel.deserialize(from: data.dictionaryObject)
            }) as? [ETOProjectModel] {
                self.store.dispatch(FetchProjectModelAction(data:projects))
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
    
    func setSelectedProjectData(_ model: ETOProjectModel) {
        self.store.dispatch(SetSelectedProjectModelAction(data: model))
        self.openProjectItem()
    }
    
    func setSelectedBannerData(_ model: ETOBannerModel) {
        self.store.dispatch(SetSelectedBannerModelAction(data: model))
        if let projectModels = self.state.data.value {
            for projectModel in projectModels {
                if let data = projectModel.projectModel {
                    if data.project == model.id {
                        self.setSelectedProjectData(data)
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
                if let projectModel = viewModel.projectModel, projectModel.status! == .pre || projectModel.status! == .ok  {
                    ETOMGService.request(target: ETOMGAPI.refreshProject(id: projectModel.id), success: { (json) in
                        if let dataJson = json.dictionaryObject, let refreshModel = ETOShortProjectStatusModel.deserialize(from: dataJson) {
                            projectModel.status = refreshModel.status
                            viewModel.current_percent.accept((refreshModel.current_percent * 100).string(digits:2, roundingMode: .down) + "%")
                            viewModel.progress.accept(refreshModel.current_percent)
                            viewModel.status.accept(refreshModel.status!.description())
                            viewModel.project_state.accept(refreshModel.status)
                        }
                    }, error: { (error) in
                    }) { (error) in
                    }
                }
            }
        }
    }
    
    func refreshTime() {
        if let projectModels = self.state.data.value {
            for viewModel in projectModels {
                if let projectModel = viewModel.projectModel, projectModel.status! == .pre || projectModel.status! == .ok  {
                    if projectModel.status! == .pre {
                        viewModel.time.accept(timeHandle(projectModel.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                    }
                    else if projectModel.status! == .ok {
                        viewModel.time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                    }
                }
            }
        }
    }
}
