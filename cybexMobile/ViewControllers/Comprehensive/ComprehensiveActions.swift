//
//  ComprehensiveActions.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON

// MARK: - State
struct ComprehensiveState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)

    var hotPairs: BehaviorRelay<[Pair]?> = BehaviorRelay(value: nil)

    var middleItems: BehaviorRelay<[ComprehensiveItem]?> = BehaviorRelay(value: nil)

    var announces: BehaviorRelay<[ComprehensiveAnnounce]?> = BehaviorRelay(value: nil)

    var banners: BehaviorRelay<[ComprehensiveBanner]?> = BehaviorRelay(value: nil)
}

// MARK: - Action
struct ComprehensiveFetchedAction: ReSwift.Action {
    var data: JSON
}

struct FetchHotAssetsAction: ReSwift.Action {
    var data: [Pair]
}

struct FetchMiddleItemAction: ReSwift.Action {
    var data: [ComprehensiveItem]
}

struct FetchAnnouncesAction: ReSwift.Action {
    var data: [ComprehensiveAnnounce]
}

struct FetchHomeBannerAction: ReSwift.Action {
    var data: [ComprehensiveBanner]
}
