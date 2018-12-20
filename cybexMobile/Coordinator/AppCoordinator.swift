//
//  AppCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ESTabBarController
import Localize_Swift
import ReSwift
import SwiftTheme
import SwifterSwift
import Repeat
import RxCocoa

class AppCoordinator {
    var fetchPariTimer: Repeater?

    var store = Store<AppState> (
        reducer: appReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: AppState {
        return store.state
    }

    var rootVC: BaseTabbarViewController

    var comprehensiveCoordinator: NavCoordinator!
    var homeCoordinator: NavCoordinator!
    var tradeCoordinator: NavCoordinator!
    var etoCoordinator: NavCoordinator!
    var accountCoordinator: NavCoordinator!
    var container: [NavCoordinator]!

    var entryCoordinator: NavCoordinator?

    weak var startLoadingVC: BaseViewController?
    var isFirstStart: Bool = true
    init(rootVC: BaseTabbarViewController) {
        self.rootVC = rootVC

        rootVC.shouldHijackHandler = {[weak self] (tab, vc, index) in
            guard let self = self else { return false }
            if self.rootVC.selectedIndex == index, let nav = vc as? BaseNavigationController {
                nav.topViewController?.refreshViewController()
            }
            return false
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (note) in
            self.fetchPariTimer?.pause()
            self.fetchPariTimer = nil
        }
    }

    func start() {
        if let tabBar = rootVC.tabBar as? ESTabBar {
            tabBar.barTintColor = UIColor.dark
            tabBar.backgroundImage = UIImage()
        }

        let comprehensive = BaseNavigationController()
        comprehensiveCoordinator = ComprehensiveCoordinator(rootVC: comprehensive)
        comprehensive.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navHome.key.localized(), image: R.image.ic_nav_home(), selectedImage: R.image.ic_nav_home_active())

        let home = BaseNavigationController()
        homeCoordinator = HomeCoordinator(rootVC: home)
        home.tabBarItem = ESTabBarItem.init(CBTabBarView(),
                                            title: R.string.localizable.navWatchlist.key.localized(),
                                            image: R.image.ic_watchlist_24px(),
                                            selectedImage: R.image.ic_watchlist_active_24px())

        let trade = BaseNavigationController()
        tradeCoordinator = TradeCoordinator(rootVC: trade)
        trade.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navTrade.key.localized(), image: R.image.icon_apply(), selectedImage: R.image.icon_apply_active())

        let account = BaseNavigationController()
        accountCoordinator = AccountCoordinator(rootVC: account)
        account.tabBarItem = ESTabBarItem.init(CBTabBarView(),
                                               title: R.string.localizable.navAccount.key.localized(),
                                               image: R.image.ic_account_box_24px(),
                                               selectedImage: R.image.ic_account_box_active_24px())

        let eto = BaseNavigationController()
        etoCoordinator = ETOCoordinator(rootVC: eto)
        eto.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navEto.key.localized(), image: R.image.ic_eto_24_px(), selectedImage: R.image.ic_eto_active_24_px())

        comprehensiveCoordinator.pushVC(ComprehensiveCoordinator.self, animated: false, context: nil)
        homeCoordinator.pushVC(HomeCoordinator.self, animated: false, context: nil)
        tradeCoordinator.pushVC(TradeCoordinator.self, animated: false, context: nil)
        accountCoordinator.pushVC(AccountCoordinator.self, animated: false, context: nil)

        if let status = AppConfiguration.shared.enableSetting.value, status.isETOEnabled == true {
            etoCoordinator.pushVC(ETOCoordinator.self, animated: false, context: nil)
            self.container = [homeCoordinator, tradeCoordinator, etoCoordinator, accountCoordinator] as [NavCoordinator]
            rootVC.viewControllers = [comprehensive, home, trade, eto, account]
        } else {
            self.container = [comprehensiveCoordinator, homeCoordinator, tradeCoordinator, accountCoordinator] as [NavCoordinator]
            rootVC.viewControllers = [comprehensive, home, trade, account]
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification),
                                               object: nil,
                                               queue: nil,
                                               using: {_ in
            CBConfiguration.sharedConfiguration.themeIndex = ThemeManager.currentThemeIndex
            CBConfiguration.sharedConfiguration.main.valueAssistTextColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1)
            CBConfiguration.sharedConfiguration.theme.longPressLineColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.1058823529, green: 0.1333333333, blue: 0.1882352941, alpha: 1)
            CBConfiguration.sharedConfiguration.theme.tickColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.4470588235, green: 0.5843137255, blue: 0.9921568627, alpha: 0.06) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04)
            CBConfiguration.sharedConfiguration.theme.dashColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.white
        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification),
                                               object: nil,
                                               queue: nil,
                                               using: {[weak self]_ in
            guard let self = self,
                let tabbarItems = self.rootVC.tabBar.items,
                let viewComtrollers = self.rootVC.viewControllers else { return }
            for(index , value) in tabbarItems.enumerated() {
                switch index {
                case 0: value.title = R.string.localizable.navHome.key.localized()
                    break
                case 1: value.title = R.string.localizable.navWatchlist.key.localized()
                    break
                case 2: value.title = R.string.localizable.navTrade.key.localized()
                    break
                case 3: value.title = viewComtrollers.count == 4 ?
                    R.string.localizable.navAccount.key.localized() : R.string.localizable.navEto.key.localized()
                    break
                case 4: value.title = R.string.localizable.navAccount.key.localized()
                    break
                default:break
                }
            }
        })
        self.rootVC.selectedIndex = 0
        aspect()
    }

    func aspect() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) {[weak self] (_) in
            guard let self = self else { return }
            self.curDisplayingCoordinator().rootVC.topViewController?.refreshViewController()
        }
    }

    func curDisplayingCoordinator() -> NavCoordinator {
        if self.rootVC.selectedIndex < self.container.count {
            return self.container[self.rootVC.selectedIndex]
        }

        return NavCoordinator(rootVC: BaseNavigationController())
    }

    func presentedViewController() -> BaseViewController? {
        if let vc = curDisplayingCoordinator().rootVC.topViewController as? BaseViewController,
            let nav = vc.presentedViewController as? BaseNavigationController,
            let top = nav.topViewController as? BaseViewController {
            return top
        }

        return nil
    }

    func topViewController() -> BaseViewController? {
        if let vc = presentedViewController() {
            return vc
        } else if let vc = curDisplayingCoordinator().rootVC.topViewController as? BaseViewController {
            return vc
        }

        return nil
    }

    func showLogin() {
        presentVC(EntryCoordinator.self, navSetup: nil, presentSetup: nil)
    }
}

extension AppCoordinator {
    func pushVC<T: NavCoordinator>(_ coordinator: T.Type, animated: Bool = true, context: RouteContext? = nil) {
        let topside = curDisplayingCoordinator().rootVC!
        let vc = coordinator.start(topside, context: context)
        topside.pushViewController(vc, animated: animated)
    }

    func presentVC<T: NavCoordinator>(_ coordinator: T.Type, animated: Bool = true, context: RouteContext? = nil,
                                      navSetup: ((BaseNavigationController) -> Void)?,
                                      presentSetup:((_ top: BaseNavigationController, _ target: BaseNavigationController) -> Void)?) {
        let nav = BaseNavigationController()
        navSetup?(nav)
        let coor = NavCoordinator(rootVC: nav)
        coor.pushVC(coordinator, animated: false, context: context)

        var topside = curDisplayingCoordinator().rootVC

        while topside?.presentedViewController != nil {
            topside = topside?.presentedViewController as? BaseNavigationController
        }

        if presentSetup == nil {
            SwifterSwift.delay(milliseconds: 100) {
                topside?.present(nav, animated: animated, completion: nil)
            }
        } else if let top = topside {
            presentSetup?(top, nav)
        }
    }

    func presentVCNoNav<T: NavCoordinator>(_ coordinator: T.Type,
                                           animated: Bool = true,
                                           context: RouteContext? = nil,
                                           presentSetup:((_ top: BaseNavigationController,
        _ target: BaseViewController) -> Void)?) {
        guard var topside = curDisplayingCoordinator().rootVC else {
            return
        }

        let viewController = coordinator.start(topside, context: context)

        while topside.presentedViewController != nil {
            if let presented = topside.presentedViewController as? BaseNavigationController {
                topside = presented
            }
        }

        if presentSetup == nil {
            SwifterSwift.delay(milliseconds: 100) {
                topside.present(viewController, animated: animated, completion: nil)
            }
        } else {
            presentSetup?(topside, viewController)
        }
    }
}
