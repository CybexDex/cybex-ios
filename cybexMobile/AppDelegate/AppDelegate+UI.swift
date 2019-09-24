//
//  AppDelegate+UI.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftRichString
import Localize_Swift
import SwiftTheme
import SwiftyUserDefaults

extension AppDelegate {
    func setupUI() {
        RichStyle.shared.start()
        configThemeAndLocalize()

        initWindow()
        self.window?.initProgressHud()
    }

    func configThemeAndLocalize() {
        UIApplication.shared.theme_setStatusBarStyle([.lightContent, .default], animated: true)

        if !Defaults.hasKey(\.theme) {
            ThemeManager.setTheme(index: 0)
        } else {
            ThemeManager.setTheme(index: Defaults[\.theme])
        }

        if !Defaults.hasKey(\.language) {
            if let language = NSLocale.preferredLanguages.first, language == "zh-Hans-CN" {
                Localize.setCurrentLanguage("zh-Hans")
            } else {
                Localize.setCurrentLanguage("en")
            }
        } else {
            Localize.setCurrentLanguage(Defaults[\.language])
        }
    }

    func initWindow() {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]
        self.window?.backgroundColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey
        window?.rootViewController = AppConfiguration.shared.appCoordinator.rootVC
        self.window?.makeKeyAndVisible()
    }    
}
