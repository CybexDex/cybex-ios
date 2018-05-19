//
//  LockupAssetsActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import RxCocoa
import RxSwift

//MARK: - State
struct LockupAssetsState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: LockupAssetsPropertyState
}


struct FetchedLockupAssetsData:Action {
  let data:[LockUpAssetsMData]
}


struct LockupAssetsPropertyState {
  var data:BehaviorRelay<LockUpAssetsVMData> = BehaviorRelay(value: LockUpAssetsVMData(datas: []))
}

struct LockUpAssetsVMData :Equatable{
  var datas : [LockupAssteData]
}
struct LockupAssteData:Equatable{
  var icon : String = ""
  var name : String = ""
  var amount : String = ""
  var RMBCount : String = ""
  var progress : String = ""
  var endTime  : String = ""
}


//MARK: - Action Creator
class LockupAssetsPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: LockupAssetsState, _ store: Store<LockupAssetsState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: LockupAssetsState,
        _ store: Store <LockupAssetsState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
  
  
  func fetchLockupAssets(with address:[String],callback:CommonAnyCallback?) -> ActionCreator{
    return { state,store in
      
      let request = getBalanceObjectsRequest(address:address) { response in
        if let callback = callback{
          callback(response)
        }
      }
      WebsocketService.shared.send(request: request)
      return nil
    }
  }
}
