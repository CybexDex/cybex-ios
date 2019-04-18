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
    var parent: NavProtocol?

    init(rootVC: BaseNavigationController) {
        self.rootVC = rootVC
        register()
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
                                      context: RouteContext?,
                                      navSetup: ((BaseNavigationController) -> Void)?,
                                      presentSetup:((_ top: BaseNavigationController,
        _ target: BaseNavigationController) -> Void)?) {
        let nav = BaseNavigationController()
        navSetup?(nav)
        let coor = NavCoordinator(rootVC: nav)
        coor.pushVC(coordinator, animated: false, context: context)

        var topside = self.rootVC

        while topside?.presentedViewController != nil {
            topside = topside?.presentedViewController as? BaseNavigationController
        }

        if presentSetup == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                topside?.present(nav, animated: animated, completion: nil)
            }
        } else if let top = topside {
            presentSetup?(top, nav)
        }
    }

    func presentVCNoNav<T: NavCoordinator>(_ coordinator: T.Type, animated: Bool = true,
                                           context: RouteContext?,
                                           presentSetup:((_ top: BaseNavigationController, _ target: BaseViewController) -> Void)?) {
        let viewController = coordinator.start(self.rootVC, context: context)
        guard var topside = self.rootVC else {
            return
        }

        while topside.presentedViewController != nil {
            if let presented = topside.presentedViewController as? BaseNavigationController {
                topside = presented
            }
        }

        if presentSetup == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                topside.present(viewController, animated: animated, completion: nil)
            }
        } else {
            presentSetup?(topside, viewController)
        }

    }

    @objc func register() {

    }
}
