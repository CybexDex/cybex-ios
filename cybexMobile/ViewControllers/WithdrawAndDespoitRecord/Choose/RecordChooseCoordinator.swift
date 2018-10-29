//
//  RecordChooseCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import SwiftyJSON
import cybex_ios_core_cpp

protocol RecordChooseCoordinatorProtocol {
}

protocol RecordChooseStateManagerProtocol {
    var state: RecordChooseState { get }

    func switchPageState(_ state: PageState)

    func fetchData(_ type: Int)
}

class RecordChooseCoordinator: NavCoordinator {
    var store = Store(
        reducer: recordChooseReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: RecordChooseState {
        return store.state
    }

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.comprehensive.recordChooseViewController()!
        let coordinator = RecordChooseCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(RecordChooseCoordinatorProtocol.self, observer: self)
        Broadcaster.register(RecordChooseStateManagerProtocol.self, observer: self)
    }
}

extension RecordChooseCoordinator: RecordChooseCoordinatorProtocol {

}

extension RecordChooseCoordinator: RecordChooseStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }

    func fetchData(_ type: Int) {
        switch type {
        case RecordChooseType.asset.rawValue:
            let accountName = UserManager.shared.name.value ?? ""
            let expiration = Int(Date().timeIntervalSince1970 + 600)
            var paragram = ["op": ["accountName": accountName, "expiration": expiration], "signer": "" ] as [String: Any]
            let operation = BitShareCoordinator.getRecodeLoginOperation(accountName, asset: "", fundType: "", size: Int32(0), offset: Int32(0), expiration: Int32(expiration))
            if let operation = operation {
                let json = JSON(parseJSON: operation)
                let signer = json["signer"].stringValue
                paragram["signer"] = signer
                SimpleHTTPService.recordLogin(paragram).done { (result) in
                    if let _ = result {
                        let url = AppConfiguration.RECODE_ACCOUNT_ASSET + "/" + accountName
                        SimpleHTTPService.fetchAccountAsset(url, signer: signer).done({ (accountAssets) in
                            if let data = accountAssets {
                                self.store.dispatch(FetchAccountAssetAction(data: data))
                            }
                        }).catch({ (_) in
                        })
                    }
                    }.catch { (_) in
                }
            }
            break
        case RecordChooseType.foudType.rawValue:

            self.store.dispatch(FetchDataAction(data: [R.string.localizable.openedAll.key.localized(),
                                                       R.string.localizable.recharge_deposit.key.localized(),
                                                       R.string.localizable.recharge_withdraw.key.localized()]))
            break
        default: break
        }
    }
}

/*
 func getWithdrawAndDepositRecords(_ accountName : String, asset : String, fundType : fundType, size : Int, offset : Int, expiration : Int ,callback:@escaping (TradeRecord?)->()) {
 
 var paragram = ["op":["accountName": accountName, "asset":asset, "fundType": fundType.rawValue, "size": Int32(size), "offset": Int32(offset),"expiration":expiration],"signer":"" ] as [String : Any]
 
 let operation = BitShareCoordinator.getRecodeLoginOperation(accountName, asset: asset, fundType: fundType.rawValue, size: Int32(size), offset: Int32(offset), expiration: Int32(expiration))
 if let operation = operation {
 let json = JSON(parseJSON: operation)
 let signer = json["signer"].stringValue
 paragram["signer"] = signer
 SimpleHTTPService.recordLogin(paragram).done { (result) in
 if let result = result {
 let url = AppConfiguration.RECODE_RECODES + "/" + accountName + "/?asset=" + asset + "&fundType=" + fundType.rawValue + "&size=" + "\(Int32(size))&offset=\(Int32(offset))"
 SimpleHTTPService.fetchRecords(url, signer: result).done({ (data) in
 callback(data)
 }).catch({ (error) in
 callback(nil)
 })
 }
 else {
 callback(nil)
 }
 }.catch { (error) in
 callback(nil)
 }
 }
 }
 */
