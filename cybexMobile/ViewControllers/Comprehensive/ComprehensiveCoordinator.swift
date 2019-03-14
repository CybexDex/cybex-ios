//
//  ComprehensiveCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import Localize_Swift

protocol ComprehensiveCoordinatorProtocol {

    func openWebVCUrl(_ url: String)

    func openMarketList(_ pair: Pair)
    func openGame(_ url: String)
}

protocol ComprehensiveStateManagerProtocol {
    var state: ComprehensiveState { get }

    func switchPageState(_ state: PageState)

    func fetchData()

    func fetchAnnounceInfos()

    func fetchHomeBannerInfos()

    func fetchHotAssetsInfos()

    func fetchMiddleItemInfos()

    func setupChildrenVC(_ sender: ComprehensiveViewController)
}

class ComprehensiveCoordinator: NavCoordinator {
    var store = Store(
        reducer: comprehensiveReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ComprehensiveState {
        return store.state
    }

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.comprehensive.comprehensiveViewController()!
        let coordinator = ComprehensiveCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(ComprehensiveCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ComprehensiveStateManagerProtocol.self, observer: self)
    }
}

extension ComprehensiveCoordinator: ComprehensiveCoordinatorProtocol {
    func openWebVCUrl(_ url: String) {
        if let webVC = R.storyboard.main.cybexWebViewController() {
            webVC.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            webVC.vcType = .homeBanner
            webVC.url = URL(string: url)
            self.rootVC.pushViewController(webVC, animated: true)
        }
    }

    func openMarketList(_ pair: Pair) {
        if let marketVC = R.storyboard.main.marketViewController() {
            marketVC.pair = pair
            marketVC.rechargeShowType = PairRechargeView.ShowType.show.rawValue
            let coordinator = MarketCoordinator(rootVC: self.rootVC)
            marketVC.coordinator = coordinator
            self.rootVC.pushViewController(marketVC, animated: true)
        }
    }
    func openGame(_ url: String) {
        if let gameVC = R.storyboard.main.gameViewController() {
            gameVC.coordinator = GameCoordinator(rootVC: self.rootVC)
            gameVC.gameURL = url
            self.rootVC.pushViewController(gameVC, animated: true)
        }
    }
}

extension ComprehensiveCoordinator: ComprehensiveStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }

    func fetchData() {
        fetchAnnounceInfos()
        fetchHomeBannerInfos()
        fetchHotAssetsInfos()
        fetchMiddleItemInfos()
    }

    func fetchAnnounceInfos() {
        AppService.request(target: .announce, success: { (json) in
            let announces = json.arrayValue.map({ ComprehensiveAnnounce.deserialize(from: $0.dictionaryObject)!})
            self.store.dispatch(FetchAnnouncesAction(data: announces))
        }, error: { (_) in

        }) { (_) in

        }
    }

    func fetchHomeBannerInfos() {
        AppService.request(target: .homebanner, success: { (json) in
            let banners = json.arrayValue.map({ ComprehensiveBanner.deserialize(from: $0.dictionaryObject)})
            if banners.count > 0 {
                self.store.dispatch(FetchHomeBannerAction(data: banners.compactMap({ $0 })))
            }
        }, error: { (_) in

        }) { (_) in

        }
    }

    func fetchHotAssetsInfos() {
        AppService.request(target: .hotpair, success: { (json) in
            let pairs = json.arrayValue.map({ Pair(base: $0.dictionaryValue["base"]?.stringValue ?? "", quote: $0.dictionaryValue["quote"]?.stringValue ?? "") })

            self.store.dispatch(FetchHotAssetsAction(data: pairs))
        }, error: { (_) in

        }) { (_) in

        }
    }

    func fetchMiddleItemInfos() {
        AppService.request(target: .items, success: { (json) in
            let data = json.arrayValue.map({ ComprehensiveItem.deserialize(from: $0.dictionaryObject)})
            self.store.dispatch(FetchMiddleItemAction(data: data.compactMap({ $0 })))
        }, error: { (_) in

        }) { (_) in

        }
    }

    func setupChildrenVC(_ sender: ComprehensiveViewController) {
        if let homeVC = R.storyboard.main.homeViewController() {
            homeVC.coordinator = HomeCoordinator(rootVC: self.rootVC)
            homeVC.vcType = ViewType.comprehensive.rawValue
            sender.addChild(homeVC)
            sender.contentView.topGainersView.addSubview(homeVC.view)
            homeVC.contentView?.edges(to: sender.contentView.topGainersView)
            homeVC.didMove(toParent: sender)
        }
    }
}
