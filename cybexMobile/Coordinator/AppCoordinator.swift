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
import EZSwiftExtensions
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
  var faqCoordinator: FAQRootCoordinator!
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
    
    let faq = BaseNavigationController()
    faqCoordinator = FAQRootCoordinator(rootVC: faq)
    faq.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navApply.key.localized(), image: R.image.icon_apply(), selectedImage: R.image.icon_apply_active())
    
    let account = BaseNavigationController()
    accountCoordinator = AccountCoordinator(rootVC: account)
    account.tabBarItem = ESTabBarItem.init(CBTabBarView(), title: R.string.localizable.navAccount.key.localized(), image: R.image.ic_account_box_24px(), selectedImage: R.image.ic_account_box_active_24px())
    
  
    //        home.tabBarItem.badgeValue = ""
    //        message.tabBarItem.badgeValue = "99+"
    
    homeCoordinator.start()
    faqCoordinator.start()
    accountCoordinator.start()
    
    rootVC.viewControllers = [home, faq, account]
   
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: {notification in     
      CBConfiguration.sharedConfiguration.themeIndex = ThemeManager.currentThemeIndex
    })
  }
  
  func curDisplayingCoordinator() -> NavCoordinator {
    let container = [homeCoordinator, faqCoordinator, accountCoordinator] as [NavCoordinator]
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
    
    ez.runThisAfterDelay(seconds: 0.1) {
      self.rootVC.present(nav, animated: true, completion: nil)
    }
  
  }
  
}

extension UIApplication {
  func coordinator() -> AppCoordinator {
    guard let d = self.delegate as? AppDelegate else { fatalError("app delegate name not match")}
    return d.appCoordinator
  }
  
  func globalState() -> AppState {
    return self.coordinator().store.state
  }
}
