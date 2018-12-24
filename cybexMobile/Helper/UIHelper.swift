//
//  UIHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

class UIHelper {
    class func getWithdrawDetailInfo(addressInfo: String,
                                     amountInfo: String,
                                     withdrawFeeInfo: String,
                                     gatewayFeeInfo: String,
                                     receiveAmountInfo: String,
                                     isEOS: Bool,
                                     memoInfo: String) -> [NSAttributedString] {
        let address: String = R.string.localizable.utils_address.key.localized()
        let amount: String = R.string.localizable.utils_amount.key.localized()
        let gatewayFee: String = R.string.localizable.utils_withdrawfee.key.localized()
        let withdrawFee: String = R.string.localizable.utils_gatewayfee.key.localized()
        let receiveAmount: String = R.string.localizable.utils_receiveamount.key.localized()
        var memo: String = R.string.localizable.withdraw_memo.key.localized()

        let content = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
        if isEOS && memoInfo.count > 0 && receiveAmountInfo.contains(AssetConfiguration.CybexAsset.XRP.rawValue) {
            memo = "Tag"
        }
        return (isEOS && memoInfo.count > 0) ?
            (["<name>\(address):</name><\(content)>\n\(addressInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(memo):</name><\(content)>  \(memoInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(amount):</name><\(content)>  \(amountInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(withdrawFee):</name><\(content)>  \(withdrawFeeInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(gatewayFee):</name><\(content)>  \(gatewayFeeInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(receiveAmount):</name><\(content)>  \(receiveAmountInfo)</\(content)>".set(style: "alertContent")] as? [NSAttributedString])! :
            (["<name>\(address):</name><\(content)>\n\(addressInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(amount):</name><\(content)>  \(amountInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(withdrawFee):</name><\(content)>  \(withdrawFeeInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(gatewayFee):</name><\(content)>  \(gatewayFeeInfo)</\(content)>".set(style: "alertContent"),
              "<name>\(receiveAmount):</name><\(content)>  \(receiveAmountInfo)</\(content)>".set(style: "alertContent")] as? [NSAttributedString])!
    }

    class func getOpenedOrderInfo(price: String, amount: String, total: String, fee: String, isBuy: Bool) -> [NSAttributedString] {
        let priceTitle = R.string.localizable.opened_order_value.key.localized()
        let amountTitle = R.string.localizable.withdraw_amount.key.localized()
        let totalTitle = R.string.localizable.trade_history_total.key.localized()
        let feeTitle = R.string.localizable.openedorder_fee_title.key.localized()

        let priceContentStyle = isBuy ? "content_buy" : "content_sell"
        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

        let result = fee.count == 0 ? (["<name>\(priceTitle): </name><\(priceContentStyle)>\(price)</\(priceContentStyle)>".set(style: "alertContent"),
                                        "<name>\(amountTitle): </name><\(contentStyle)>\(amount)</\(contentStyle)>".set(style: "alertContent"),
                                        "<name>\(totalTitle): </name><\(contentStyle)>\(total)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])! :
            (["<name>\(priceTitle): </name><\(priceContentStyle)>\(price)</\(priceContentStyle)>".set(style: "alertContent"),
              "<name>\(amountTitle): </name><\(contentStyle)>\(amount)</\(contentStyle)>".set(style: "alertContent"),
              "<name>\(totalTitle): </name><\(contentStyle)>\(total)</\(contentStyle)>".set(style: "alertContent"),
              "<name>\(feeTitle): </name><\(contentStyle)>\(fee)</\(contentStyle)>".set(style: "alertContent") ] as? [NSAttributedString])!

        return  result
    }

    class func getCancelOrderConfirmInfo() -> [NSAttributedString] {
        let message = R.string.localizable.openedorder_ensure_message.key.localized()

        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

        let result = (["<\(contentStyle)>\(message)\n\n                                     </\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])!

        return result
    }

    class func getTransferInfo(_ account: String, quanitity: String, fee: String, memo: String) -> [NSAttributedString] {
        let accountTitle = R.string.localizable.transfer_account_title.key.localized()
        let quantityTitle = R.string.localizable.transfer_quantity.key.localized()
        let feeTitle = R.string.localizable.transfer_fee.key.localized()
        let memoTitle = R.string.localizable.transfer_memo.key.localized()

        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

        return memo.trimmed.count != 0 ? (["<name>\(accountTitle):</name>  <\(contentStyle)>\(account)</\(contentStyle)>".set(style: "alertContent"),
                                           "<name>\(quantityTitle):</name><\(contentStyle)>  \(quanitity)</\(contentStyle)>".set(style: "alertContent"),
                                           "<name>\(feeTitle):</name><\(contentStyle)>  \(fee)</\(contentStyle)>".set(style: "alertContent"),
                                           "<name>\(memoTitle):</name><\(contentStyle)>  \(memo)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])! :
            (["<name>\(accountTitle):</name>  <\(contentStyle)>\(account)</\(contentStyle)>".set(style: "alertContent"),
              "<name>\(quantityTitle):</name><\(contentStyle)>  \(quanitity)</\(contentStyle)>".set(style: "alertContent"),
              "<name>\(feeTitle):</name><\(contentStyle)>  \(fee)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])!
    }

    class func claimLockupAsset(_ info: LockupAssteData) -> [NSAttributedString] {

        guard let name = UserManager.shared.name.value else { return []}
        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
        var result: [NSAttributedString] = []

        let quantity = R.string.localizable.transfer_quantity.key.localized()
        let account = R.string.localizable.transfer_account_title.key.localized()

        let amount = info.amount + " " +  info.name.filterJade
        let quantityInfo = "<name>\(quantity):</name> <\(contentStyle)>" + amount + "</\(contentStyle)>"
        let accountInfo = "<name>\(account):</name> <\(contentStyle)>" + name + "</\(contentStyle)>"

        result.append(quantityInfo.set(style: StyleNames.alertContent.rawValue)!)
        result.append(accountInfo.set(style: StyleNames.alertContent.rawValue)!)
        return result
    }

    class func confirmDeleteWithDrawAddress(_ info: WithdrawAddress) -> [NSAttributedString] {

        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
        let isEOS = info.currency == AssetConfiguration.CybexAsset.EOS.id
        let existMemo = info.memo != nil && !info.memo!.isEmpty

        var result: [NSAttributedString] = []
        let title = "<\(contentStyle)>" +
            (isEOS ? R.string.localizable.delete_confirm_account.key.localized() : R.string.localizable.delete_confirm_address.key.localized()) +
        "</\(contentStyle)>"
        result.append(title.set(style: StyleNames.alertContent.rawValue)!)

        let note = "<name>" +
            R.string.localizable.address_mark.key.localized() +
            "：</name>" + "<\(contentStyle)>" +
            "\(info.name)" +
        "</\(contentStyle)>"
        result.append(note.set(style: StyleNames.alertContent.rawValue)!)

        let address = "<name>" +
            (isEOS ? R.string.localizable.accountTitle.key.localized() : R.string.localizable.address.key.localized()) +
            "：</name>" +
            "<\(contentStyle)>" +
            "\(info.address)" +
        "</\(contentStyle)>"
        result.append(address.set(style: StyleNames.alertContent.rawValue)!)

        if existMemo {
            let memo = "<name>" + R.string.localizable.withdraw_memo.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.memo!)" + "</\(contentStyle)>"
            result.append(memo.set(style: StyleNames.alertContent.rawValue)!)
        }

        return result
    }

    class func confirmDeleteTransferAddress(_ info: TransferAddress) -> [NSAttributedString] {
        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

        var result: [NSAttributedString] = []

        let title = "<\(contentStyle)>" + R.string.localizable.delete_confirm_account.key.localized() + "</\(contentStyle)>"
        result.append(title.set(style: StyleNames.alertContent.rawValue)!)

        let note = "<name>" + R.string.localizable.address_mark.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.name)" + "</\(contentStyle)>"
        result.append(note.set(style: StyleNames.alertContent.rawValue)!)

        let address = "<name>" + R.string.localizable.accountTitle.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.address)" + "</\(contentStyle)>"
        result.append(address.set(style: StyleNames.alertContent.rawValue)!)

        return result
    }

    class func confirmSubmitCrowd(_ name: String, amount: String, fee: String) -> [NSAttributedString] {
        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"

        var result: [NSAttributedString] = []

        let title = R.string.localizable.eto_submit_title.key.localizedFormat(name).tagText(contentStyle)
        result.append(title.set(style: StyleNames.alertContent.rawValue)!)

        let note = (R.string.localizable.transfer_quantity.key.localized() + ": ").tagText("name") + amount.tagText(contentStyle)

        result.append(note.set(style: StyleNames.alertContent.rawValue)!)

        let address = (R.string.localizable.transfer_fee.key.localized() + ": " ).tagText("name") + fee.tagText(contentStyle)
        result.append(address.set(style: StyleNames.alertContent.rawValue)!)

        return result
    }
}

