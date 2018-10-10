//
//  RechargeRecodeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol RechargeRecodeCoordinatorProtocol {
    func openRecordDetailUrl(_ hash:String, asset: String)
}

protocol RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeRecodeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func fetchRechargeRecodeList(_ accountName : String ,asset : String ,fundType : fundType ,size : Int , offset : Int ,expiration : Int ,asset_id : String ,callback:@escaping (Bool)->())
    
    func setAssetAction(_ asset : String)
    
    func fetchAssetUrl()
}

class RechargeRecodeCoordinator: AccountRootCoordinator {
    
    lazy var creator = RechargeRecodePropertyActionCreate()
    
    var store = Store<RechargeRecodeState>(
        reducer: RechargeRecodeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension RechargeRecodeCoordinator: RechargeRecodeCoordinatorProtocol {
    func openRecordDetailUrl(_ hash:String, asset: String) {
        guard let explorers = self.state.property.explorers.value else { return }
        var url = ""
        for explorer in explorers {
            if explorer.asset.filterJade == asset {
                url = explorer.explorer + hash
            }
        }
        if url.count == 0 {
            for explorer in explorers {
                if explorer.asset.filterJade == "ETH" {
                    url = explorer.explorer + hash
                }
            }
        }
        if let vc = self.rootVC.topViewController as? WithdrawAndDespoitRecordViewController{
            vc.coordinator?.openRecordDetailUrl(url)
        }
        else {
            if let vc = R.storyboard.main.cybexWebViewController() {
                vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
                vc.vc_type = .recordDetail
                vc.url = URL(string: url)
                self.rootVC.pushViewController(vc ,animated: true)
            }
        }
    }
}

extension RechargeRecodeCoordinator: RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeRecodeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
    func fetchRechargeRecodeList(_ accountName : String ,asset : String ,fundType : fundType ,size : Int , offset : Int ,expiration : Int ,asset_id : String, callback:@escaping (Bool)->()) {
        getWithdrawAndDepositRecords(accountName, asset: asset, fundType: fundType, size: size, offset: offset, expiration: expiration) { [weak self](result) in
            guard let `self` = self else { return }
            self.store.dispatch(FetchDepositRecordsAction(data : result))
            if result != nil {
                callback(true)
            }else {
                callback(false)
            }
        }
    }
    
    func setAssetAction(_ asset : String) {
        self.store.dispatch(SetWithdrawListAssetAction(asset : asset))
    }
    
    func fetchAssetUrl() {
        SimpleHTTPService.fetchBlockexplorerJson().done { [weak self](explorers) in
            guard let `self` = self else { return }
            self.store.dispatch(FetchAssetUrlAction(data: explorers))
            }.catch { (error) in
        }
    }
}
