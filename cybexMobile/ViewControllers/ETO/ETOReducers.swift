//
//  ETOReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ETOReducer(action:Action, state:ETOState?) -> ETOState {
    let state = state ?? ETOState()
    switch action {
    case let action as FetchProjectModelAction:
        state.data.accept(transferModelToViewModel(action.data))
        break
    case let action as FetchBannerModelAction:
        state.banners.accept(action.data)
    case let action as SetSelectedProjectModelAction:
        state.selectedProjectModel.accept(action.data)
    case let action as SetSelectedBannerModelAction:
        state.selectedProjectModel.accept(nil)
        state.selectedBannerModel.accept(action.data)
    default:break
    }
    return state
}

func transferModelToViewModel(_ data : [ETOProjectModel]) -> [ETOProjectViewModel] {
    var viewModels = [ETOProjectViewModel]()
    for model in data {
        viewModels.append(ETOProjectViewModel(model))
    }
    return viewModels
}
