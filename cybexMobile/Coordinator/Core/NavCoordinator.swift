//
//  NavCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwifterSwift

protocol RouteContext {}

protocol NavProtocol {
    func openWebVC(url: URL)

    func pushVC<T: NavCoordinator>(_ coordinator: T.Type, animated: Bool, context: RouteContext?)
    func presentVC<T: NavCoordinator>(_ coordinator: T.Type,
                                      animated: Bool,
                                      context: RouteContext?,
                                      navSetup: ((BaseNavigationController) -> Void)?,
                                      presentSetup:((_ top: BaseNavigationController, _ target: BaseNavigationController) -> Void)?)

    func register()
}

class NavCoordinator: NavProtocol {
    weak var rootVC: BaseNavigationController!

    init(rootVC: BaseNavigationController) {
        self.rootVC = rootVC
        register()
    }

    func start() {

    }

    class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        return BaseViewController()
    }
}

extension NavCoordinator {
    func openWebVC(url: URL) {
        let web = BaseWebViewController()
        web.url = url

        self.rootVC.pushViewController(web, animated: true)
    }

    func pushVC<T: NavCoordinator>(_ coordinator: T.Type, animated: Bool = true, context: RouteContext? = nil) {
        let vc = coordinator.start(self.rootVC, context: context)
        self.rootVC.pushViewController(vc, animated: animated)
    }

    func presentVC<T: NavCoordinator>(_ coordinator: T.Type, animated: Bool = true,
                                     context: RouteContext? = nil,
                                     navSetup: ((BaseNavigationController) -> Void)?,
                                     presentSetup:((_ top: BaseNavigationController, _ target: BaseNavigationController) -> Void)?) {
        let nav = BaseNavigationController()
        navSetup?(nav)
        let coor = NavCoordinator(rootVC: nav)
        coor.pushVC(coordinator, animated: false, context: context)

        var topside = self.rootVC!

        while topside.presentedViewController != nil {
            topside = topside.presentedViewController as! BaseNavigationController
        }

        if presentSetup == nil {
            SwifterSwift.delay(milliseconds: 100) {
                topside.present(nav, animated: animated, completion: nil)
            }
        } else {
            presentSetup?(topside, nav)
        }

    }

    @objc func register() {

    }
}
