//
//  UIImage+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme
import Localize_Swift

extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }

    class func themeAndLocalizedImage() -> UIImage {
        let black = ThemeManager.currentThemeIndex == 0
        let en = Localize.currentLanguage() == "en"

        if black, en {
            return R.image.img_contest_en_dark()!
        } else if black, !en {
            return R.image.img_contest_cn_dark()!
        } else if !black, en {
            return R.image.img_contest_en_lignt()!
        } else {
            return R.image.img_contest_cn_lignt()!
        }
    }
}
