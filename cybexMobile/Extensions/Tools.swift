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
        }
        else if lhs.major == rhs.major {
            if lhs.minor < rhs.minor {
                return true
            }
            else if lhs.minor == rhs.minor {
                if lhs.patch < rhs.patch {
                    return true
                }
                
            }
        }
        
        
        
        return false
    }
    
}

func prettyPrint(with json: [String: Any]) -> String {
    let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    let string = String(data: data, encoding: .utf8)!
    return string
}

extension UIViewController {
    
    func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier: identifier]
        storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                guard let `self` = self else { return }
                
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
    
    
    func handlerUpdateVersion(_ completion: CommonCallback?, showNoUpdate: Bool = false ) {
        async {
            let (update, url, force ,content) = try! await(SimpleHTTPService.checkVersion())
            main {
                if let completion = completion {
                    completion()
                }
                if update {
                    
                    let contentView = StyleContentView(frame: .zero)
                    ShowToastManager.shared.setUp(title: R.string.localizable.update_version.key.localized(), contentView: contentView, animationType: ShowToastManager.ShowAnimationType.small_big)
                    ShowToastManager.shared.showAnimationInView(self.view)
                    
                    
                    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
                    if content.contains("\n"){
                        contentView.data = content.replacingOccurrences(of: "\n", with: "\\").components(separatedBy: "\\").map({ (string) in
                            "<\(contentStyle)>\(string)</\(contentStyle)>".set(style: "alertContent")!
                        })
                    }else{
                        contentView.data = ["<\(contentStyle)>\(content)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString]
                    }
                    
                    ShowToastManager.shared.isShowSingleBtn = force
                    
                    ShowToastManager.shared.ensureClickBlock = {
                        if force {
                            UIApplication.shared.openURL(URL(string: url)!)
                            return
                        }
                        if url.contains("itunes") {
                            self.openStoreProductWithiTunesItemIdentifier(AppConfiguration.APPID)
                        }
                        else {
                            self.openSafariViewController(url)
                        }
                    }
                    
                    
                    //          let alert = AlertController(title: R.string.localizable.updata_available_title.key.localized(), message: R.string.localizable.updata_available_message.key.localized(), preferredStyle: .alert)
                    //
                    //          if !force {
                    //            alert.addAction(AlertAction(title: R.string.localizable.updata_next_time.key.localized(), style: .normal, handler: nil))
                    //          }
                    //          else {
                    //            alert.shouldDismissHandler = { (action) in
                    //              if action?.title == R.string.localizable.updata_next_time.key.localized() {
                    //                return true
                    //              }
                    //              else {
                    //                action!.handler!(action!)
                    //                return false
                    //              }
                    //            }
                    //          }
                    //
                    //          let action = AlertAction(title: R.string.localizable.updata_updata.key.localized(), style: .preferred, handler: { (action) in
                    //                      if force {
                    //                        UIApplication.shared.openURL(URL(string: url)!)
                    //                        return
                    //                      }
                    //                      if url.contains("itunes") {
                    //                        self.openStoreProductWithiTunesItemIdentifier(AppConfiguration.APPID)
                    //                      }
                    //                      else {
                    //                        self.openSafariViewController(url)
                    //                      }
                    //          })
                    //          alert.addAction(action)
                    //          alert.present()
                }
                else if showNoUpdate {
                    let alert = AlertController(title: R.string.localizable.unupdata_title.key.localized(), message: R.string.localizable.unupdata_message.key.localized(), preferredStyle: .alert)
                    alert.addAction(AlertAction(title: R.string.localizable.unupdata_ok.key.localized(), style: .normal, handler: nil))
                    alert.present()
                }
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
        return infoDictionary!["CFBundleShortVersionString"] as! String
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
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
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
    var stringValue:String {
        return NSDecimalNumber(decimal: self).stringValue
    }
    
    var doubleValue:Double {
        let str = self.stringValue
        
        if let d = Double(str) {
            return d
        }
        return 0
    }
    
    func tradePrice() -> (price:String, pricision:Int) {
        var pricision = 0
        if self < Decimal(floatLiteral: 0.0001) {
            pricision = 8
        }
        else if self < Decimal(floatLiteral: 1) {
            pricision = 6
        }
        else {
            pricision = 4
        }
        
        return (self.string(digits: pricision), pricision)
    }
    
    func string(digits:Int = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        var decimal = self
        var drounded = Decimal()
        NSDecimalRound(&drounded, &decimal, digits, roundingMode)
        
        if digits == 0 {
            return drounded.stringValue
        }
        
        var formatterString : String = "0."
        
        for _ in 0 ..< digits {
            formatterString.append("0")
        }
        
        let formatter = NumberFormatter()
        formatter.positiveFormat = formatterString
        
        return formatter.string(from: NSDecimalNumber(decimal: drounded)) ?? "0"
    }
}

extension Double {
    func string(digits:Int = 0,roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        let decimal = Decimal(floatLiteral: self)
        
        return decimal.string(digits: digits,roundingMode:roundingMode)
    }
    
    func preciseString() -> String {//解决显示科学计数法的格式
        let decimal = Decimal(floatLiteral: self)
        
        return decimal.stringValue
    }
    
    func tradePrice() -> (price:String, pricision:Int ,amountPricision : Int) {
        var pricision = 0
        var amountPricision = 0
        let decimal = Decimal(floatLiteral: self)
        if decimal < Decimal(floatLiteral: 0.0001) {
            pricision = 8
            amountPricision = 2
        }
        else if decimal < Decimal(floatLiteral: 1) {
            pricision = 6
            amountPricision = 4
        }
        else {
            pricision = 4
            amountPricision = 6
        }
        
        return (self.string(digits: pricision), pricision , amountPricision)
    }
    
    func formatCurrency(digitNum: Int ,usesGroupingSeparator:Bool = true) -> String {
        if self < 1000 {
            return string(digits: digitNum,roundingMode:.down)
        }
        
        let existFormatters = String.numberFormatters.filter({ (formatter) -> Bool in
            return formatter.maximumFractionDigits == digitNum && formatter.usesGroupingSeparator == usesGroupingSeparator
        })
        
        if let format = existFormatters.first {
            let result = format.string(from: NSNumber(value: self))
            return result!
        }
        else {
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
    
    func suffixNumber(digitNum: Int = 5) -> String {
        var num = self
        let sign = ((num < 0) ? "-" : "")
        num = fabs(num)
        if (num < 1000.0) {
            return "\(sign)\(num.string(digits:digitNum))"
        }
        
        let exp: Int = Int(log10(num) / 3.0)
        let units: [String] = ["k", "m", "b"]
        
        let precision = pow(1000.0, exp.double)
        num = 100 * num / precision
        
        let result = num.rounded() / 100.0
        
        //    let roundedNum = round(100.0 * num / pow(1000.0, Double(exp))) / 100.0
        
        return "\(sign)\(result.string(digits: 2))" + "\(units[exp - 1])"
    }
}

extension String {
    static var numberFormatters:[NumberFormatter] = []
    static var doubleFormat:NumberFormatter = NumberFormatter()
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self) // "Mar 22, 2017, 10:22 AM"
    }
    
    var filterJade:String {
        return self.replacingOccurrences(of: "JADE.", with: "")
    }
    
    var getID:Int32 {
        if self == "" {
            return 0
        }
        
        if let id = self.components(separatedBy: ".").last {
            return Int32(id)!
        }
        
        return 0
    }
    
    var tradePrice:(price:String, pricision:Int ,amountPricision : Int) {//0.0001  1   8 6 4
        if let oldPrice = self.toDouble() {
            return oldPrice.tradePrice()
        }
        
        return (self, 0 , 0)
    }
    
    public func toDouble() -> Double? {
        if self == "" {
            return 0
        }
        
        var selfString = self
        if selfString.contains(","){
            selfString = selfString.replacingOccurrences( of:"[^0-9.]", with: "", options: .regularExpression)
        }
        
        return Double(selfString)
    }
    
    
    public func toDecimal() -> Decimal? {
        if self == "" {
            return Decimal(0)
        }
        var selfString = self
        if selfString.contains(","){
            selfString = selfString.replacingOccurrences( of:"[^0-9.]", with: "", options: .regularExpression)
        }
        return Decimal(string:selfString)
    }
    
    
    func formatCurrency(digitNum: Int) -> String {
        
        if let str = toDouble()?.formatCurrency(digitNum: digitNum) {
            return str
        }
        return ""
    }
    
    func suffixNumber(digitNum: Int = 5) -> String {
        if let str = Double(self)?.suffixNumber(digitNum:digitNum) {
            return str
        }
        return ""
    }
}


func transferTimeType(_ time: Int, type: Bool = false) -> String {
    var result = ""
    var times = 0

    if time == 0 {
        result = "0"
        return result + R.string.localizable.transfer_unit_second.key.localized()
    }
    
    if time / (3600 * 24) != 0 {
        result = "\(time / (3600 * 24))" + R.string.localizable.transfer_unit_day.key.localized()
    }
    times = time % (3600 * 24)
    if times / 3600 != 0 {
        if type == true, result != "" {
            result += " \(times / 3600)" + R.string.localizable.transfer_unit_hour.key.localized()
            return result
        }
        result += " \(times / 3600)" + R.string.localizable.transfer_unit_hour.key.localized()
    }
    times = times % 3600
    if times / 60 != 0 {
        if type == true, result != "" {
            result += " \(times / 60)" + R.string.localizable.transfer_unit_minite.key.localized()
            return result
        }
        result += " \(times / 60)" + R.string.localizable.transfer_unit_minite.key.localized()
    }
    times = times % 60
    if times != 0 {
        result += " \(times)" + R.string.localizable.transfer_unit_second.key.localized()
    }
    return result
}


func timeHandle(_ time: Double, isHiddenSecond: Bool = true) -> String {
    var result = ""
    var intTime = time.int
    
    if isHiddenSecond == true, intTime < 60 {
        return R.string.localizable.eto_time_less_minite.key.localized()
    }
    result += "\(intTime / (3600 * 24))" + R.string.localizable.transfer_unit_day.key.localized() + " "
    intTime = intTime % (3600 * 24)
    result += "\(intTime / 3600)" + R.string.localizable.transfer_unit_hour.key.localized() + " "
    intTime = intTime % 3600
    result += "\(intTime / 60)" + R.string.localizable.transfer_unit_minite.key.localized()
    if isHiddenSecond == false {
        intTime = intTime % 60
        result += " \(intTime)" + R.string.localizable.transfer_unit_second.key.localized()
    }
    return result
}


func verifyPassword(_ password : String) -> (Bool) {
    if password.count < 12 {
        return false
    }
    
    let guiter = Guitar(pattern: "(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[^a-zA-Z0-9]).{12,}")
    if !guiter.test(string: password) {
        return false
    }
    else {
        return true
    }
}


