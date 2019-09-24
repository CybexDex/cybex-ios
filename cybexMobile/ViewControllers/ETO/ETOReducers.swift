//
//  ETOReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift

func ETOReducer(action: ReSwift.Action, state: ETOState?) -> ETOState {
    let state = state ?? ETOState()
    switch action {
    case let action as FetchProjectModelAction:
        state.data.accept(transferModelToViewModel(action.data))
    case let action as FetchBannerModelAction:
        state.banners.accept(action.data)
        state.bannerUrls.accept(transferBannersToUrls(action.data))
    case let action as SetSelectedProjectModelAction:
        state.selectedProjectModel.accept(action.data)
    case let action as SetSelectedBannerModelAction:
        state.selectedProjectModel.accept(nil)
        state.selectedBannerModel.accept(action.data)
    case let action as ResetBannerUrlsAction:
        state.bannerUrls.accept(transferBannersToUrls(action.data))
    default:break
    }
    return state
}

func transferModelToViewModel(_ data: [ETOProjectModel]) -> [ETOProjectViewModel] {
    var viewModels = [ETOProjectViewModel]()
    for model in data {
        viewModels.append(ETOProjectViewModel(model))
    }
    return viewModels
}

func transferBannersToUrls(_ data: [ETOBannerModel]) -> [String]? {
    return data.map({ Localize.currentLanguage() == "en" ? $0.addsBannerMobileLangEn : $0.addsBannerMobile })
}
