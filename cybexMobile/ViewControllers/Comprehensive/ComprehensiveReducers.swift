//
//  ComprehensiveReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ComprehensiveReducer(action: Action, state: ComprehensiveState?) -> ComprehensiveState {
    let state = state ?? ComprehensiveState()

    switch action {

    case let action as FetchHotAssetsAction:
        state.hotPairs.accept(action.data)
    case let action as FetchMiddleItemAction:
        state.middleItems.accept(action.data)
    case let action as FetchAnnouncesAction:
        state.announces.accept(action.data)
    case let action as FetchHomeBannerAction:
        state.banners.accept(bannerSorting(action.data))
    default:
        break
    }

    return state
}

func bannerSorting(_ banners: [ComprehensiveBanner]) -> [ComprehensiveBanner] {
    if banners.count < 2 {
        return banners
    }
    return banners.sorted(by: { return $0.score > $1.score })
}
