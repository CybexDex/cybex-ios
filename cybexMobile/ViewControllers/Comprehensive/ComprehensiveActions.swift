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

//MARK: - State
struct ComprehensiveState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    
    var hotPairs: BehaviorRelay<[Pair]?> = BehaviorRelay(value: nil)
    
    var middleItems: BehaviorRelay<[ComprehensiveItem]?> = BehaviorRelay(value: nil)
    
    var announces: BehaviorRelay<[ComprehensiveAnnounce]?> = BehaviorRelay(value: nil)
    
    var banners: BehaviorRelay<[ComprehensiveBanner]?> = BehaviorRelay(value: nil)
}

//MARK: - Action
struct ComprehensiveFetchedAction: Action {
    var data:JSON
}

struct FetchHotAssetsAction: Action {
    var data: [Pair]
}

struct FetchMiddleItemAction: Action {
    var data: [ComprehensiveItem]
}

struct FetchAnnouncesAction: Action {
    var data: [ComprehensiveAnnounce]
}

struct FetchHomeBannerAction: Action {
    var data: [ComprehensiveBanner]
}
