//
//  WithdrawAddressHomeReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import RxCocoa

func withdrawAddressHomeReducer(action: ReSwift.Action, state: WithdrawAddressHomeState?) -> WithdrawAddressHomeState {
    let state = state ?? WithdrawAddressHomeState()

    switch action {

    case let action as FecthWithdrawIds:
        state.data.accept(convertTradeToWithDrawAddressHomeViewModel(action.data))
    case let action as WithdrawAddressHomeSelectedAction:
        if action.index < state.data.value.count {
            let viewModel = state.data.value[action.index]

            if let address = state.addressData.value[viewModel.model.id] {
                state.selectedViewModel.accept((viewModel, address))
            }

        }
    case let action as WithdrawAddressHomeAddressDataAction:
        let data = state.data.value
        for viewmodel in data {
            if let addressData = action.data[viewmodel.model.id] {
                viewmodel.count.accept("\(addressData.count)")
            }
        }

        state.addressData.accept(action.data)

    default:
        break
    }

    return state
}

func convertTradeToWithDrawAddressHomeViewModel(_ data: [Trade]) -> [WithdrawAddressHomeViewModel] {
    var viewmodels: [WithdrawAddressHomeViewModel] = []

    for trade in data {
        let imageURLString = AppConfiguration.ServerIconsBaseURLString + trade.id.replacingOccurrences(of: ".", with: "_") + "_grey.png"
        guard let info = appData.assetInfo[trade.id] else {
            break
        }

        let viewmodel = WithdrawAddressHomeViewModel(imageURLString: imageURLString, count: BehaviorRelay(value: ""), name: info.symbol.filterSystemPrefix, model: trade)
        viewmodels.append(viewmodel)
    }

    return viewmodels
}
