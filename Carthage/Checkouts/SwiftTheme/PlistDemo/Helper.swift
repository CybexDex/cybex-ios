//
//  Helper.swift
//  PlistDemo
//
//  Created by Gesen on 16/3/15.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import Foundation


let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]


extension UIViewController {

    func showHUD(_ text: String) -> MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.label.text = text
        HUD.removeFromSuperViewOnHide = true
        return HUD
    }
    
}
