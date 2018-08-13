//
//  NavCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

protocol NavProtocol {
    func openWebVC(url:URL)
}

class NavCoordinator:NavProtocol {
    
    weak var rootVC: BaseNavigationController!
    
    init(rootVC: BaseNavigationController) {
        self.rootVC = rootVC
    }
    
    func start()  {
        
    }
    
    func register() {
        
    }
}

extension NavCoordinator {
    func openWebVC(url:URL) {
        let web = BaseWebViewController()
        web.url = url
        
        self.rootVC.pushViewController(web, animated: true)
    }
    
}
