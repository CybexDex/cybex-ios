//
//  AppCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ESTabBarController_swift
import Localize_Swift
import ReSwift
import SwiftTheme
import SwifterSwift
import Repeat

protocol AppStateManagerProtocol {
  var state: AppState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<AppState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchData(_ params:AssetPairQueryParams, sub:Bool)
  func fetchEthToRmbPrice()
}

class AppCoordinator {
  lazy var creator = AppPropertyActionCreate()
  
  var timer:Repeater?
  
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
  var tradeCoordinator : TradeRootCoordinator!
  var accountCoordinator: AccountRootCoordinator!
  var entryCoordinator: EntryRootCoordinator!

  weak var currentPresentedRootCoordinator: NavCoordinator?
  
  weak var startLoadingVC:BaseViewController?

  init(rootVC: BaseTabbarViewController) {
    self.rootVC = rootVC
  }
  
  func start() {
    if let tabBar = rootVC.tabBar as? ESTabBar {
      tabBar.barTintColor = UIColor.dark
      tabBar.backgroundImage = UIImage()
    }
    
    let home = BaseNavigationController()

    homeCoordinator = HomeRootCoordinator(rootVC: home)
    home.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navWatchlist.key.localized(), image: R.image.ic_watchlist_24px(), selectedImage: R.image.ic_watchlist_active_24px())
    
    let trade = BaseNavigationController()
    tradeCoordinator = TradeRootCoordinator(rootVC: trade)
    trade.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navTrade.key.localized(), image: R.image.icon_apply(), selectedImage: R.image.icon_apply_active())
    
    
    let account = BaseNavigationController()
    accountCoordinator = AccountCoordinator(rootVC: account)
    account.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navAccount.key.localized(), image: R.image.ic_account_box_24px(), selectedImage: R.image.ic_account_box_active_24px())
    
  
    //        home.tabBarItem.badgeValue = ""
    //        message.tabBarItem.badgeValue = "99+"
    
    homeCoordinator.start()
    tradeCoordinator.start()
    accountCoordinator.start()
    
    rootVC.viewControllers = [home, trade, account]
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: {notification in     
      CBConfiguration.sharedConfiguration.themeIndex = ThemeManager.currentThemeIndex
      CBConfiguration.sharedConfiguration.main.valueAssistTextColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1)
      CBConfiguration.sharedConfiguration.theme.longPressLineColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.1058823529, green: 0.1333333333, blue: 0.1882352941, alpha: 1)
      CBConfiguration.sharedConfiguration.theme.tickColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.4470588235, green: 0.5843137255, blue: 0.9921568627, alpha: 0.06) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.04)
      CBConfiguration.sharedConfiguration.theme.dashColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.white

    })
  }
  
  func curDisplayingCoordinator() -> NavCoordinator {
    let container = [homeCoordinator, tradeCoordinator, accountCoordinator] as [NavCoordinator]
    return container[self.rootVC.selectedIndex]
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

