//
//  RecordChooseReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func recordChooseReducer(action: ReSwift.Action, state: RecordChooseState?) -> RecordChooseState {
    let state = state ?? RecordChooseState()

    switch action {
    case let action as FetchDataAction:
        state.data.accept(action.data)
    case let action as FetchAccountAssetAction:
        state.data.accept(transferAccountAsset(action.data))
    default:
        break
    }

    return state
}

func transferAccountAsset(_ sender: AccountAssets) -> [String] {
    if let records = sender.records {
        var data = records.map({ (model) -> String in
            return model.groupInfo?.asset ?? ""
        })
        data.insert(R.string.localizable.openedAll.key.localized(), at: 0)
        return data
    }
    return [R.string.localizable.openedAll.key.localized()]
}
