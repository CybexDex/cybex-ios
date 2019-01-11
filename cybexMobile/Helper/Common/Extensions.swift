//
//  Tools.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SafariServices
import StoreKit
import SDCAlertView
import SwiftTheme
import Guitar
import Localize_Swift
import HandyJSON

struct AppVersionResult {
    var update: Bool = false
    var url: String = ""
    var force: Bool = false
    var content: String = ""
}

public struct Version: Equatable, Comparable {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let string: String?
    
    public init?(_ version: String) {
        
        let parts: Array<String> = version.split { $0 == "." }.map { String($0) }
        
        if let majorOptional = parts[optional: 0], let minorOptional = parts[optional: 1], let patchOptional = parts[optional: 2],
            let majorInt = Int(majorOptional), let minorInt = Int(minorOptional), let patchInt = Int(patchOptional) {
            self.major = majorInt
            self.minor = minorInt
            self.patch = patchInt
            string = version
        } else {
            return nil
        }
    }
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major == rhs.major {
            if lhs.minor < rhs.minor {
                return true
            } else if lhs.minor == rhs.minor {
                if lhs.patch < rhs.patch {
                    return true
                }
                
            }
        }
        
        return false
    }
    
}

extension UIView {
    var heightWithSafeAreaTop: CGFloat {
        guard let rootView = UIApplication.shared.keyWindow else { return 0 }

        if #available(iOS 11.0, *) {
            let topInset = rootView.safeAreaInsets.top

            return self.height + topInset
        } else {
            return self.height
        }
    }

    var windowSafeAreaInsets: UIEdgeInsets {
        guard let rootView = UIApplication.shared.keyWindow else { return UIEdgeInsets.zero }

        if #available(iOS 11.0, *) {
            return rootView.safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }

    var windowWithNavSafeAreaInsets: UIEdgeInsets {
        return windowSafeAreaInsets.insetBy(top: 44)
    }

    var windowWithNavAndBottomSafeAreaInsets: UIEdgeInsets {
        return windowWithNavSafeAreaInsets.insetBy(bottom: 44)
    }
}

extension UIViewController {
    
    func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier: identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, _) -> Void in
            if loaded {
                guard let self = self else { return }
                
                self.present(storeViewController, animated: true)
            }
        }
    }
    
    func openSafariViewController(_ urlString: String) {
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self
            
            self.present(vc, animated: true)
        }
    }

    func requestLastestVersion(_ callback: @escaping (AppVersionResult) -> Void) {
        var target: AppAPI = AppAPI.checkAppStoreVersionUpdate
        if !AppConfiguration.shared.isAppStoreVersion() {
            target = .checkVersionUpdate
        }

        AppService.request(target: target, success: { (json) in
            let lastestVersion = json["version"].stringValue

            if let cur = Version(Bundle.main.version), let remote = Version(lastestVersion) {
                if cur >= remote {
                    callback(AppVersionResult())
                    return
                }

                let forceData = json["force"]

                let result = AppVersionResult(update: true, url: json["url"].stringValue,
                                              force: forceData[Bundle.main.version].boolValue,
                                              content: Localize.currentLanguage() == "en" ?  json["enUpdateInfo"].stringValue : json["cnUpdateInfo"].stringValue)
                callback(result)
            }
        }, error: { (_) in
            callback(AppVersionResult())
        }) { (_) in
            callback(AppVersionResult())
        }

    }
    
    func handlerUpdateVersion(_ completion: CommonCallback?, showNoUpdate: Bool = false ) {
        requestLastestVersion { (result) in
            if let completion = completion {
                completion()
            }
            if result.update {

                let contentView = StyleContentView(frame: .zero)
                ShowToastManager.shared.setUp(title: R.string.localizable.update_version.key.localized(), contentView: contentView, animationType: ShowToastManager.ShowAnimationType.smallBig)
                ShowToastManager.shared.showAnimationInView(self.view)

                let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
                if result.content.contains("\n") {
                    contentView.data = result.content.replacingOccurrences(of: "\n", with: "\\").components(separatedBy: "\\").map({ (string) in
                        "<\(contentStyle)>\(string)</\(contentStyle)>".set(style: "alertContent")!
                    })
                } else {
                    contentView.data = ["<\(contentStyle)>\(result.content)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString]
                }

                ShowToastManager.shared.isShowSingleBtn = result.force
                ShowToastManager.shared.ensureClickBlock = {
                    if result.force {
                        UIApplication.shared.open(URL(string: result.url)!, options: [:], completionHandler: nil)
                        return
                    }

                    self.openSafariViewController(result.url)
                }
            } else if showNoUpdate {
                let alert = AlertController(title: R.string.localizable.unupdata_title.key.localized(), message: R.string.localizable.unupdata_message.key.localized(), preferredStyle: .alert)
                alert.addAction(AlertAction(title: R.string.localizable.unupdata_ok.key.localized(), style: .normal, handler: nil))
                alert.present()
            }
        }
    }
}

extension UIViewController: SKStoreProductViewControllerDelegate {
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss(animated: true)
    }
}

extension UIViewController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

extension Bundle {
    var version: String {
        guard let ver = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return ver
    }
}

extension NSLayoutConstraint {
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
    
}
extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX") //不设置系统默认地区 为格式化后的语言
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 默认为系统当前的时区
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension Decimal { // 解决double 计算精度丢失
    var stringValue: String {
        return NSDecimalNumber(decimal: self).stringValue
    }

    var int64Value: Int64 {
        return NSDecimalNumber(decimal: self).int64Value
    }

    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }

    var floor: Decimal {
        return decimal(digits: 0, roundingMode: .down)
    }

    var ceil: Decimal {
        return decimal(digits: 0, roundingMode: .up)
    }

    func decimal(digits: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var decimal = self
        var drounded = Decimal()
        NSDecimalRound(&drounded, &decimal, digits, roundingMode)

        return drounded
    }

    func string(digits: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        return decimal(digits: digits, roundingMode: roundingMode).stringValue
    }

    func double(digits: Int = Int.max, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Double {
        if digits == Int.max {
            return Double(stringValue) ?? 0
        }
        return Double(string(digits: digits, roundingMode: roundingMode)) ?? 0
    }

    func cgfloat(digits: Int = Int.max, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> CGFloat {
        if digits == Int.max {
            return CGFloat(exactly: NSDecimalNumber(decimal: self)) ?? 0
        }
        return CGFloat(exactly: NSDecimalNumber(decimal: decimal(digits: digits, roundingMode: roundingMode))) ?? 0
    }
    

    func tradePrice(_ roundingMode: NSDecimalNumber.RoundingMode = .plain) -> (price: String, pricision: Int) {
        var pricision = 0
        if self < Decimal(floatLiteral: 0.0001) {
            pricision = 8
        } else if self < Decimal(floatLiteral: 1) {
            pricision = 6
        } else {
            pricision = 4
        }
        return (self.formatCurrency(digitNum: pricision), pricision)
    }

    func tradePriceAndAmountDecimal(_ roundingMode: NSDecimalNumber.RoundingMode = .plain) -> (price: String, pricision: Int, amountPricision: Int) {
        var pricision = 0
        var amountPricision = 0
        if self < Decimal(floatLiteral: 0.0001) {
            pricision = 8
            amountPricision = 2
        } else if self < Decimal(floatLiteral: 1) {
            pricision = 6
            amountPricision = 4
        } else {
            pricision = 4
            amountPricision = 6
        }
        return (self.formatCurrency(digitNum: pricision), pricision, amountPricision)
    }

    //小于1000的时候 digitNum 大于1000 统一2位
    func suffixNumber(digitNum: Int = 5, padZero: Bool = true) -> String {
        var num = self
        let sign = ((num < 0) ? "-" : "")
        num = abs(num)

        if num / 1000 < 1 {
            let str = num.string(digits: digitNum, roundingMode: .down)
            let result = padZero ? str.formatCurrency(digitNum: digitNum, usesGroupingSeparator: false) : str
            return "\(sign)\(result)"
        }

        num /= 1000
        if num / 1000 < 1  {
            let str = num.string(digits: 2, roundingMode: .down)
            let result = padZero ? str.formatCurrency(digitNum: 2, usesGroupingSeparator: false) : str
            return "\(sign)\(result)" + "k"
        }
        num /= 1000
        if num / 1000 < 1 {
            let str = num.string(digits: 2, roundingMode: .down)
            let result = padZero ? str.formatCurrency(digitNum: 2, usesGroupingSeparator: false) : str

            return "\(sign)\(result)" + "m"
        }
        num /= 1000

        let str = num.string(digits: 2, roundingMode: .down)
        let result = padZero ? str.formatCurrency(digitNum: 2, usesGroupingSeparator: false) : str

        return "\(sign)\(result)" + "b"
    }

    // 对齐小数位 不足补0
    func formatCurrency(digitNum: Int, usesGroupingSeparator: Bool = false) -> String {
        let existFormatters = String.numberFormatters.filter({ (formatter) -> Bool in
            return formatter.maximumFractionDigits == digitNum && formatter.usesGroupingSeparator == usesGroupingSeparator
        })
        if let format = existFormatters.first {
            let result = format.string(from: NSDecimalNumber(decimal: self))
            return result!
        } else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = ""
            numberFormatter.roundingMode = .floor
            numberFormatter.usesGroupingSeparator = usesGroupingSeparator
            numberFormatter.maximumFractionDigits = digitNum
            numberFormatter.minimumFractionDigits = digitNum
            String.numberFormatters.append(numberFormatter)
            return self.formatCurrency(digitNum: digitNum)
        }
    }
}

extension Double {
    var decimal: Decimal {
        return Decimal(self)
    }
    
    // 对齐小数位 不足补0
    func formatCurrency(digitNum: Int, usesGroupingSeparator: Bool = false) -> String {
        let existFormatters = String.numberFormatters.filter({ (formatter) -> Bool in
            return formatter.maximumFractionDigits == digitNum && formatter.usesGroupingSeparator == usesGroupingSeparator
        })
        if let format = existFormatters.first {
            let result = format.string(from: NSDecimalNumber(decimal: self.decimal))
            return result!
        } else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = ""
            numberFormatter.usesGroupingSeparator = usesGroupingSeparator
            numberFormatter.maximumFractionDigits = digitNum
            numberFormatter.minimumFractionDigits = digitNum
            String.numberFormatters.append(numberFormatter)
            return self.formatCurrency(digitNum: digitNum)
        }
    }

    func string(digits: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        let decimal = Decimal(floatLiteral: self)
        
        return decimal.string(digits: digits, roundingMode: roundingMode)
    }

    func tradePriceAndAmountDecimal(_ roundingMode: NSDecimalNumber.RoundingMode = .plain) -> (price: String, pricision: Int, amountPricision: Int) {
        return self.decimal.tradePriceAndAmountDecimal(roundingMode)
    }

    func suffixNumber(digitNum: Int = 5, padZero: Bool = true) -> String {
        return decimal.suffixNumber(digitNum: digitNum, padZero: padZero)
    }
}

extension Int {
    var decimal: Decimal {
        return Decimal(self)
    }
}

extension String {
    static var numberFormatters: [NumberFormatter] = []
    static var doubleFormat: NumberFormatter = NumberFormatter()
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self) // "Mar 22, 2017, 10:22 AM"
    }
    
    var filterJade: String {
        // 正式
        return self.replacingOccurrences(of: "JADE.", with: "").replacingOccurrences(of: "JADE_", with: "").replacingOccurrences(of: "JADE", with: "")
    }
    
    var getSuffixID: Int32 {
        if self == "" {
            return 0
        }
        
        if let id = self.components(separatedBy: ".").last {
            return Int32(id)!
        }
        
        return 0
    }

    var int32: Int32 {
        if self == "" {
            return 0
        }
        
        return Int32(self)!
    }
    
    func tradePriceAndAmountDecimal(_ roundingMode: NSDecimalNumber.RoundingMode = .plain) -> (price: String, pricision: Int, amountPricision: Int) {
        return self.decimal().tradePriceAndAmountDecimal(roundingMode)
    }

    public func decimal() -> Decimal {
        if self == "" {
            return Decimal(0)
        }
        var selfString = self
        if selfString.contains(",") {
            selfString = selfString.replacingOccurrences( of: "[^0-9.]", with: "", options: .regularExpression)
        }
        return Decimal(string: selfString) ?? Decimal(0)
    }

    func string(digits: Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        return decimal().decimal(digits: digits, roundingMode: roundingMode).stringValue
    }

    func formatCurrency(digitNum: Int, usesGroupingSeparator: Bool = false) -> String {
        return decimal().formatCurrency(digitNum: digitNum, usesGroupingSeparator: usesGroupingSeparator)
    }
    
    func suffixNumber(digitNum: Int = 5, padZero: Bool = true) -> String {
        return decimal().suffixNumber(digitNum: digitNum, padZero: padZero)
    }
}





