//
//  URLNavigationMap.swift
//  cybexMobile
//
//  Created by koofrank on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

/// example: openPage("cybexapp://eto/home")
struct URLNavigationMap {
    static func initialize(navigator: NavigatorType) {
        navigator.handle("cybexapp://eto/home") { (_, _, _) -> Bool in
            if let vcs = appCoodinator.rootVC.viewControllers {
                let types = vcs.compactMap({ ($0 as? BaseNavigationController)?.viewControllers.first })

                if let index = types.firstIndex(where: { $0.className == ETOViewController.self.typeName}) {
                    appCoodinator.rootVC.selectedIndex = index
                    return true
                }
            }

            return false
        }

        navigator.handle("cybexapp://eto/project/<pid>") { (_, values, context) -> Bool in
            appCoodinator.pushVC(ETODetailCoordinator.self, animated: true, context: ETODetailContext.deserialize(from: values))
            return true
        }

        navigator.handle("cybexapp://deposit") { (_, _, context) -> Bool in
            var context = RechargeContext()
            context.selectedIndex = RechargeViewController.CellType.RECHARGE

            appCoodinator.pushVC(RechargeCoordinator.self, animated: true, context: context)

            return true
        }

        navigator.handle("cybexapp://withdraw") { (_, _, context) -> Bool in
            var context = RechargeContext()
            context.selectedIndex = RechargeViewController.CellType.WITHDRAW
            appCoodinator.pushVC(RechargeCoordinator.self, animated: true, context: context)

            return true
        }

        navigator.handle("cybexapp://transfer") { (_, values, context) -> Bool in
            appCoodinator.pushVC(TransferCoordinator.self, animated: true, context: TransferContext.deserialize(from: values))
            return true
        }

        navigator.handle("cybexapp://exchange") { (url, _, _) -> Bool in
            if let vcs = appCoodinator.rootVC.viewControllers {
                let types = vcs.compactMap({ ($0 as? BaseNavigationController)?.viewControllers.first })

                if let index = types.firstIndex(where: { $0.className == TradeViewController.self.typeName}),
                    let vc = types[index] as? TradeViewController,
                    let bid = url.queryParameters["base"],
                    let qid = url.queryParameters["quote"] {
                    appCoodinator.rootVC.selectedIndex = index
                    vc.view.backgroundColor = vc.view.backgroundColor // 先执行viewdidload
                    vc.pair = Pair(base: bid, quote: qid)

                    return true
                }
            }

            return false
        }
    }
}
