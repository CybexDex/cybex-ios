//
//  UIUtils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

//转账详情 锁定期解锁时间格式
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

//ETO 时间格式
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

func labelBaselineOffset(_ lineHeight: CGFloat, fontHeight: CGFloat) -> Float {
    return ((lineHeight - lineHeight) / 4.0).float
}

func openPage(_ urlString: String) {
    if let url = urlString.url {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

func saveImageToPhotos() {
    guard let window = UIApplication.shared.keyWindow else { return }

    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)

    window.layer.render(in: UIGraphicsGetCurrentContext()!)

    let image = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
}
