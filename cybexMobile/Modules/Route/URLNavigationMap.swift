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
        navigator.handle("cybexapp://eto/home") { (url, values, context) -> Bool in
            if let vcs = app_coodinator.rootVC.viewControllers {
                let types = vcs.compactMap( { ($0 as? BaseNavigationController)?.viewControllers.first })
                
                if let index = types.firstIndex(where: { $0.className == ETOViewController.self.typeName}) {
                    app_coodinator.rootVC.selectedIndex = index
                    return true
                }
            }
            
            return false
        }
        
        navigator.handle("cybexapp://eto/project/<pid>") { (url, values, context) -> Bool in
            app_coodinator.pushVC(ETODetailCoordinator.self, animated: true, context: ETODetailContext.deserialize(from: values))
            return true
        }

        navigator.handle("cybexapp://deposit") { (url, values, context) -> Bool in
            var context = RechargeContext()
            context.selectedIndex = RechargeViewController.CELL_TYPE.RECHARGE
            
            app_coodinator.pushVC(RechargeCoordinator.self, animated: true, context: context)
            
            return true
        }

        navigator.handle("cybexapp://withdraw") { (url, values, context) -> Bool in
            var context = RechargeContext()
            context.selectedIndex = RechargeViewController.CELL_TYPE.WITHDRAW
            app_coodinator.pushVC(RechargeCoordinator.self, animated: true, context: context)
            return true
        }

        navigator.handle("cybexapp://transfer") { (url, values, context) -> Bool in
            app_coodinator.pushVC(TransferCoordinator.self, animated: true, context: TransferContext.deserialize(from: values))
            return true
        }

        navigator.handle("cybexapp://exchange") { (url, values, context) -> Bool in
            if let vcs = app_coodinator.rootVC.viewControllers {
                let types = vcs.compactMap( { ($0 as? BaseNavigationController)?.viewControllers.first })
                
                if let index = types.firstIndex(where: { $0.className == TradeViewController.self.typeName}),
                    let vc = types[index] as? TradeViewController,
                    let bid = url.queryParameters["base"],
                    let qid = url.queryParameters["quote"] {
                    app_coodinator.rootVC.selectedIndex = index
                    vc.view.backgroundColor = vc.view.backgroundColor // 先执行viewdidload
                    vc.pair = Pair(base: bid, quote: qid)
                    
                    return true
                }
            }
            
            return false
        }
    }
}
