//
//  Vesting.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class LockUpAssetsMData: Mappable, NSCopying {
    var id: String = ""
    var owner: String = ""
    var balance: Asset = Asset(JSON: [:])!
    var vesting_policy: VestingPolicy = VestingPolicy(JSON: [:])!
    var last_claim_date: String = ""

    required init?(map: Map) {
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LockUpAssetsMData(JSON: self.toJSON())!
        return copy
    }

    func mapping(map: Map) {
        id                  <- (map["id"], ToStringTransform())
        owner               <- (map["owner"], ToStringTransform())
        balance             <- map["balance"]
        vesting_policy      <- map["vesting_policy"]
        last_claim_date     <- (map["last_claim_date"], ToStringTransform())
    }
}

class VestingPolicy: Mappable {
    var begin_timestamp: String = ""
    var vesting_cliff_seconds: String = ""
    var vesting_duration_seconds: String = ""
    var begin_balance: String = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        begin_timestamp                <- (map["begin_timestamp"], ToStringTransform())
        vesting_cliff_seconds          <- (map["vesting_cliff_seconds"], ToStringTransform())
        vesting_duration_seconds       <- (map["vesting_duration_seconds"], ToStringTransform())
        begin_balance                  <- (map["begin_balance"], ToStringTransform())
    }
}

// 可用资产的页面数据
class PortfolioData {
    var icon: String = ""
    var name: String = "--"
    var realAmount: String = ""
    var cybPrice: String = ""
    var rbmPrice: String = ""

    required init?(balance: Balance) {

        icon = AppConfiguration.SERVER_ICONS_BASE_URLString + balance.asset_type.replacingOccurrences(of: ".", with: "_") + "_grey.png"
        // 获得自己的个数
        if let asset_info = app_data.assetInfo[balance.asset_type] {
            realAmount = getRealAmount(balance.asset_type, amount: balance.balance).string(digits: asset_info.precision, roundingMode: .down)
            name = asset_info.symbol.filterJade
        }

        // 获取对应CYB的个数
        let amountCYB = app_data.cyb_rmb_price == 0 ? "-" :  String(getAssetRMBPrice(balance.asset_type) / app_data.cyb_rmb_price * (realAmount.toDouble())!)

        if amountCYB == "-"{
            cybPrice = amountCYB + " CYB"
        } else {
            cybPrice = amountCYB.formatCurrency(digitNum: 5) + " CYB"
        }

        if let _ = amountCYB.toDouble() {
            rbmPrice    = "≈¥" + (getRealAmount(balance.asset_type, amount: balance.balance) * Decimal(getAssetRMBPrice(balance.asset_type))).string(digits: 2, roundingMode: .down)
        } else {
            rbmPrice    = "-"
        }
    }
}

// 我的资产的页面数据
class MyPortfolioData {
    var icon: String = ""
    var name: String = ""
    var realAmount: String = ""
    var rbmPrice: String = ""
    var limitAmount: String = ""

    required init?(balance: Balance) {
        icon = AppConfiguration.SERVER_ICONS_BASE_URLString + balance.asset_type.replacingOccurrences(of: ".", with: "_") + "_grey.png"

        name = app_data.assetInfo[balance.asset_type]?.symbol.filterJade ?? "--"
        // 获得自己的个数
        if let asset_info = app_data.assetInfo[balance.asset_type] {
            realAmount = getRealAmount(balance.asset_type, amount: balance.balance).string(digits: asset_info.precision, roundingMode: .down)
        }

        // 获取对应CYB的个数
        let amountCYB = app_data.cyb_rmb_price == 0 ? "-" :  String(getAssetRMBPrice(balance.asset_type) / app_data.cyb_rmb_price * (realAmount.toDouble())!)

//        let amountCYB = changeToETHAndCYB(balance.asset_type).cyb == "0" ? "-" :  String(changeToETHAndCYB(balance.asset_type).cyb.toDouble()! * (realAmount.toDouble())!)

        if let _ = amountCYB.toDouble() {
            rbmPrice = "≈¥" + (getRealAmount(balance.asset_type, amount: balance.balance) * Decimal(getAssetRMBPrice(balance.asset_type))).string(digits: 2, roundingMode: .down)
        } else {
            rbmPrice = "-"
        }

        //获取冻结资产
        var limitDecimal: Decimal = 0

        if let limitArray = UserManager.shared.limitOrder.value {
            for limit in limitArray {
                if limit.sellPrice.base.assetID == balance.asset_type {
                    let amount = getRealAmount(balance.asset_type, amount: limit.forSale)
                    limitDecimal = limitDecimal + amount
                }
            }
            if let asset_info = app_data.assetInfo[balance.asset_type] {
                if limitDecimal == 0 {
                    limitAmount = R.string.localizable.frozen.key.localized() + "--"
                } else {
                    log.debug("limitAmountlimitAmount\(limitDecimal.doubleValue)")
                    limitAmount = R.string.localizable.frozen.key.localized() + limitDecimal.string(digits: asset_info.precision, roundingMode: .down)
                }
            }
        }
    }
}
