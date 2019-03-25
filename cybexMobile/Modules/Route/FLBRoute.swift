//
//  FLBRoute.swift
//  cybexMobile
//
//  Created by koofrank on 2019/3/25.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import flutter_boost

class FLBRoute: NSObject, FLBPlatform {
    func openPage(_ name: String, params: [AnyHashable : Any], animated: Bool, completion: @escaping (Bool) -> Void) {
        if let isPresented = params["present"] as? Bool, isPresented {
            let vc = FLBFlutterViewContainer()
            vc.setName(name, params: params)
            appCoodinator.curDisplayingCoordinator().rootVC?.present(vc, animated: true, completion: nil)
        }
        else {
            let vc = FLBFlutterViewContainer()
            vc.setName(name, params: params)
            appCoodinator.curDisplayingCoordinator().rootVC?.pushViewController(vc, animated: true)
        }
    }

    func closePage(_ uid: String, animated: Bool, params: [AnyHashable : Any], completion: @escaping (Bool) -> Void) {
        if let vc = appCoodinator.curDisplayingCoordinator().rootVC?.presentedViewController as? FLBFlutterViewContainer,
            vc.uniqueIDString == uid {
            vc.dismiss(animated: true, completion: nil)
        } else {
            appCoodinator.curDisplayingCoordinator().rootVC?.popViewController()
        }

    }

    static var shared = FLBRoute()


}
