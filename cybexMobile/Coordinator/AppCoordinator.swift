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

protocol AppStateManagerProtocol {
    var state: AppState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AppState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
//    func fetchData(_ params: AssetPairQueryParams, sub: Bool, priority: Operation.QueuePriority, callback:@escaping ()->())
    func fetchData(_ params: AssetPairQueryParams, sub: Bool, priority: Operation.QueuePriority)
    
    func fetchTickerData(_ params: AssetPairQueryParams, sub: Bool, priority: Operation.QueuePriority)
    func fetchEthToRmbPrice()
    
    func fetchGetToCyb(_ callback:@escaping(Decimal)->())
}

class AppCoordinator {
    lazy var creator = AppPropertyActionCreate()
    
    var timer:Repeater?
    
    var fetchPariTimer:Repeater?
    
    var getToCybRelation : Decimal?
    
    var store = Store<AppState> (
        reducer: AppReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: AppState {
        return store.state
    }
    
    var rootVC: BaseTabbarViewController
    
    var homeCoordinator: HomeRootCoordinator!
    var explorerCoordinator: ExplorerRootCoordinator!
    //  var faqCoordinator: FAQRootCoordinator!
    var tradeCoordinator: TradeRootCoordinator!
    var accountCoordinator: AccountRootCoordinator!
    var entryCoordinator: EntryRootCoordinator!
    var etoCoordinator: ETORootCoordinator!
    var comprehensiveCoordinator: ComprehensiveRootCoordinator!
    var container : [NavCoordinator]!
    
    var etoStatus: BehaviorRelay<ETOHidden?> = BehaviorRelay(value:nil)
    
    weak var currentPresentedRootCoordinator: NavCoordinator?
    
    weak var startLoadingVC:BaseViewController?
    
    init(rootVC: BaseTabbarViewController) {
        self.rootVC = rootVC
        
        rootVC.shouldHijackHandler = {[weak self] (tab, vc, index) in
            guard let `self` = self else { return false }
            if self.rootVC.selectedIndex == index, let nav = vc as? BaseNavigationController {
                nav.topViewController?.refreshViewController()
            }
            
            return false
        }
    }
    
    func start() {
        if let tabBar = rootVC.tabBar as? ESTabBar {
            tabBar.barTintColor = UIColor.dark
            tabBar.backgroundImage = UIImage()
        }
        
        let comprehensive = BaseNavigationController()
        comprehensiveCoordinator = ComprehensiveRootCoordinator(rootVC: comprehensive)
        comprehensive.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navHome.key.localized(), image: R.image.ic_nav_home(), selectedImage: R.image.ic_nav_home_active())
        
        let home = BaseNavigationController()
        homeCoordinator = HomeRootCoordinator(rootVC: home)
        home.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navWatchlist.key.localized(), image: R.image.ic_watchlist_24px(), selectedImage: R.image.ic_watchlist_active_24px())
        
        let trade = BaseNavigationController()
        tradeCoordinator = TradeRootCoordinator(rootVC: trade)
        trade.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navTrade.key.localized(), image: R.image.icon_apply(), selectedImage: R.image.icon_apply_active())
        
        
        let account = BaseNavigationController()
        accountCoordinator = AccountCoordinator(rootVC: account)
        account.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navAccount.key.localized(), image: R.image.ic_account_box_24px(), selectedImage: R.image.ic_account_box_active_24px())
        
        let eto = BaseNavigationController()
        etoCoordinator = ETORootCoordinator(rootVC: eto)
        eto.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navEto.key.localized(), image: R.image.ic_eto_24_px(), selectedImage: R.image.ic_eto_active_24_px())
        
        //        home.tabBarItem.badgeValue = ""
        //        message.tabBarItem.badgeValue = "99+"
        comprehensiveCoordinator.start()
        homeCoordinator.start()
        tradeCoordinator.start()
        accountCoordinator.start()
        
        if let status = self.etoStatus.value, status.isETOEnabled == true {
            etoCoordinator.start()
            self.container = [homeCoordinator, tradeCoordinator, etoCoordinator,accountCoordinator] as [NavCoordinator]
            rootVC.viewControllers = [comprehensive, home, trade, eto, account]
        }
        else {
            self.container = [comprehensiveCoordinator,homeCoordinator, tradeCoordinator, accountCoordinator] as [NavCoordinator]
            rootVC.viewControllers = [comprehensive, home, trade, account]
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: {notification in
            CBConfiguration.sharedConfiguration.themeIndex = ThemeManager.currentThemeIndex
            CBConfiguration.sharedConfiguration.main.valueAssistTextColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1)
            CBConfiguration.sharedConfiguration.theme.longPressLineColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.1058823529, green: 0.1333333333, blue: 0.1882352941, alpha: 1)
            CBConfiguration.sharedConfiguration.theme.tickColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.4470588235, green: 0.5843137255, blue: 0.9921568627, alpha: 0.06) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04)
            CBConfiguration.sharedConfiguration.theme.dashColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.white
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: {notification in
            comprehensive.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navHome.key.localized(), image: R.image.ic_nav_home(), selectedImage: R.image.ic_nav_home_active())

            home.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navWatchlist.key.localized(), image: R.image.ic_watchlist_24px(), selectedImage: R.image.ic_watchlist_active_24px())
            trade.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navTrade.key.localized(), image: R.image.icon_apply(), selectedImage: R.image.icon_apply_active())
            
            eto.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navEto.key.localized(), image: R.image.ic_eto_24_px(), selectedImage: R.image.ic_eto_active_24_px())
            account.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navAccount.key.localized(), image: R.image.ic_account_box_24px(), selectedImage: R.image.ic_account_box_active_24px())
            self.rootVC.selectedIndex = self.rootVC.viewControllers!.count - 1
        })
        
        aspect()
    }
    
    func aspect() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) {[weak self] (notifi) in
            guard let `self` = self else { return }
            self.curDisplayingCoordinator().rootVC.topViewController?.refreshViewController()
        }
    }
    
    func curDisplayingCoordinator() -> NavCoordinator {
        return self.container[self.rootVC.selectedIndex]
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
        }
        else if let vc = curDisplayingCoordinator().rootVC.topViewController as? BaseViewController {
            return vc
        }
        
        return nil
    }
    
    func showLogin() {
        let nav = BaseNavigationController()
        entryCoordinator = EntryRootCoordinator(rootVC: nav)
        entryCoordinator.start()
        currentPresentedRootCoordinator = entryCoordinator
        
        SwifterSwift.delay(milliseconds: 100) {
            self.rootVC.present(nav, animated: true, completion: nil)
        }
    }
}

extension AppCoordinator {
    func pushVC<T:NavCoordinator>(_ coordinator: T.Type, animated:Bool = true, context:RouteContext? = nil) {
        let topside = curDisplayingCoordinator().rootVC!
        let vc = coordinator.start(topside, context: context)
        topside.pushViewController(vc, animated: animated)
    }
    
    func presentVC<T:NavCoordinator>(_ coordinator: T.Type, animated:Bool = true, context:RouteContext? = nil,
                                     navSetup: ((BaseNavigationController) -> Void)?,
                                     presentSetup:((_ top:BaseNavigationController, _ target:BaseNavigationController) -> Void)?) {
        let nav = BaseNavigationController()
        navSetup?(nav)
        let coor = NavCoordinator(rootVC: nav)
        coor.pushVC(coordinator, animated: false, context: context)
        
        var topside = curDisplayingCoordinator().rootVC!
        
        while topside.presentedViewController != nil  {
            topside = topside.presentedViewController as! BaseNavigationController
        }
        
        if presentSetup == nil {
            SwifterSwift.delay(milliseconds: 100) {
                topside.present(nav, animated: animated, completion: nil)
            }
        }
        else {
            presentSetup?(topside, nav)
        }
    }
}
