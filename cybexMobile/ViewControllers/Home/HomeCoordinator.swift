//
//  HomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol HomeCoordinatorProtocol {
    func openMarket(index: Int, currentBaseIndex: Int)
}

protocol HomeStateManagerProtocol {
    var state: HomeState { get }
    func switchPageState(_ state: PageState)
    func sortedHomeDataWith()
}

class HomeCoordinator: HomeRootCoordinator {
    var store = Store(
        reducer: homeReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
    
    var state: HomeState {
        return store.state
    }
}

extension HomeCoordinator: HomeCoordinatorProtocol {
    func openMarket(index: Int, currentBaseIndex: Int) {
        let vc = R.storyboard.main.marketViewController()!
        vc.curIndex = index
        vc.currentBaseIndex = currentBaseIndex
        vc.rechargeShowType = PairRechargeView.ShowType.show.rawValue
        
        let coordinator = MarketCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }
}

extension HomeCoordinator: HomeStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
    
    func sortedHomeDataWith() {
        let nameData = appData.tickerData.value.sorted { (first, second) -> Bool in
            guard let firstInfo = appData.assetInfo[first.quote], let secondInfo = appData.assetInfo[second.quote] else { return false}
            return firstInfo.symbol.filterJade < secondInfo.symbol.filterJade
        }
        
        let volumeData = appData.tickerData.value.sorted { (first, second) -> Bool in
            guard let firstDecimal = first.baseVolume.toDecimal(), let secondDecimal = second.baseVolume.toDecimal()
                else { return false}
            return firstDecimal > secondDecimal
        }
        
        let priceData = appData.tickerData.value.sorted { (first, second) -> Bool in
            guard let firstPrice = first.latest.toDecimal(), let secondPrice = second.latest.toDecimal() else {return false}
            return firstPrice > secondPrice
        }
        
        let appliesData = appData.tickerData.value.sorted { (first, second) -> Bool in
            guard let firstApplies = first.percentChange.toDecimal(), let secondApplies = second.percentChange.toDecimal() else {return false}
            return firstApplies > secondApplies
        }
        
    }
}
