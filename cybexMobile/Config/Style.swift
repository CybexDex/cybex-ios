//
//  Style.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftRichString
import Localize_Swift
import SwiftTheme

enum StyleNames: String {
    case introduceNormal
    case introduce
    case password
    case withdrawIntroduce
    case alertContent
    case address
    case bold12With20
    case bold14With24
}

enum LineViewStyleNames: String {
    case normalName
    case normalContent
    case transferConfirm
}

extension Style {
    func setupLineHeight(_ lineHeight: CGFloat, fontHeight: CGFloat) {
        self.maximumLineHeight = lineHeight
        self.minimumLineHeight = lineHeight
        self.baselineOffset = labelBaselineOffset(lineHeight, fontHeight: lineHeight)
    }
}

class RichStyle {
    static var shared = RichStyle()

    func start() {

    }

    private init() {
        changeStyleFromTheme()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: {_ in
            self.start()
            self.changeStyleFromTheme()
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: {_ in
            self.start()
            self.changeStyleFromTheme()
        })
    }

    //PingFangSC-Regular_12_#F7F8FAFF_20
    func constructStyle(_ fontSize: CGFloat = 12,
                        color: UIColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo,
                        lineHeight: CGFloat = 20,
                        font: SystemFonts = SystemFonts.PingFangSC_Regular) {
        let style = Style {
            let realfont = font.font(size: fontSize)
            $0.font = realfont
            $0.color = color

            $0.setupLineHeight(lineHeight, fontHeight: realfont.lineHeight)
        }

        Styles.register("\(font.rawValue)_\(fontSize)_\(color.hexString(true))_\(lineHeight)", style: style)
    }

    func changeStyleFromTheme() {
        let style = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
            $0.lineSpacing = 8.0
        }
        Styles.register(StyleNames.introduceNormal.rawValue, style: style)

        let introduceStyle = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
            $0.lineSpacing = 4.0
        }
        Styles.register(StyleNames.introduce.rawValue, style: introduceStyle)

        let withStyle = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
            $0.lineSpacing = 4.0
        }
        Styles.register(StyleNames.withdrawIntroduce.rawValue, style: withStyle)

        let bold12With20 = Style {
            let font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.font = font
            $0.color = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo

            $0.setupLineHeight(20, fontHeight: font.lineHeight)
        }

        let bold14With24 = Style {
            let font = SystemFonts.PingFangSC_Regular.font(size: 14)
            $0.font = font
            $0.color = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo

            $0.setupLineHeight(24, fontHeight: font.lineHeight)
        }

        Styles.register(StyleNames.bold12With20.rawValue, style: bold12With20)
        Styles.register(StyleNames.bold14With24.rawValue, style: bold14With24)

        passwordStyle()
        alertDetailStyle()
        initLineViewStyle()
        addressStyle()

    }

    func addressStyle() {
        let base = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12.0)
        }

        let nodeDark = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.lineSpacing = 4
            $0.color = UIColor.white
        }

        let nodeWhite = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.lineSpacing = 4
            $0.color = UIColor.darkTwo
        }

        let address = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.lineSpacing = 4
            $0.color = UIColor.steel
        }

        let myGroup = StyleGroup(base: base, ["node_dark": nodeDark, "node_white": nodeWhite, "address": address])
        StylesManager.shared.register(StyleNames.address.rawValue, style: myGroup)
    }

    func passwordStyle() {
        let normal = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14)
            $0.lineSpacing = 4
            $0.color = UIColor.steel
        }

        let password = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14)
            $0.color = UIColor.maincolor
        }

        let myGroup = StyleGroup(base: normal, ["password": password])
        Styles.register(StyleNames.password.rawValue, style: myGroup)
    }

    func alertDetailStyle() {
        let base = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
        }

        let name = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
        }

        let contentBuy = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.turtleGreen
        }

        let contentSell = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.reddish
        }

        let contentDark = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.white
        }

        let contentLight = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.darkTwo
        }

        let myGroup = StyleGroup(base: base, ["name": name, "content_dark": contentDark, "content_light": contentLight, "content_sell": contentSell, "content_buy": contentBuy])
        StylesManager.shared.register(StyleNames.alertContent.rawValue, style: myGroup)
    }

    func initLineViewStyle() {
        let nameStyle = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 16.0)
        }
        Styles.register(LineViewStyleNames.normalName.rawValue, style: nameStyle)

        let contentStyle = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
        }
        Styles.register(LineViewStyleNames.normalContent.rawValue, style: contentStyle)

        let confirmStyle = Style {
            $0.font = SystemFonts.PingFangSC_Semibold.font(size: 16.0)
        }
        Styles.register(LineViewStyleNames.transferConfirm.rawValue, style: confirmStyle)

    }
}
