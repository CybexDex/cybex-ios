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
    func openBanner()
    func openProjectHistroy()
}

protocol ETOStateManagerProtocol {
    var state: ETOState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchProjectData()
    
    func fetchBannersData()
    
    func setSelectedProjectData(_ model: ETOProjectModel)
    
    func setSelectedBannerData(_ model: ETOBannerModel)
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
    func openProjectItem(_ model: ETOProjectModel) {
        if let vc = R.storyboard.etoDetail.etoDetailViewController() {
            vc.coordinator = ETODetailCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
    
    func openBanner() {
        
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
            
        }) { (error) in
            
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
        }) { (error) in
        }
    }
    
    func setSelectedProjectData(_ model: ETOProjectModel) {
        self.store.dispatch(SetSelectedProjectModelAction(data: model))
        self.openProjectItem(model)
    }
    
    func setSelectedBannerData(_ model: ETOBannerModel) {
        self.store.dispatch(SetSelectedBannerModelAction(data: model))
        if let projectModels = self.state.data.value {
            for projectModel in projectModels {
                if let data = projectModel.model {
                    if data.project == model.id {
                        self.setSelectedProjectData(data)
                        break
                    }
                }
            }
        }
    }
}
