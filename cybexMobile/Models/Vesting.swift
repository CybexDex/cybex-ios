//
//  Vesting.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class LockUpAssetsMData: HandyJSON, NSCopying {
    var id: String = ""
    var owner: String = ""
    var balance: Asset = Asset()
    var vestingPolicy: VestingPolicy = VestingPolicy()
    var lastClaimDate: String = ""

    required init() {
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LockUpAssetsMData.deserialize(from: self.toJSON())
        return copy ?? LockUpAssetsMData()
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< id                  <-- ("id", ToStringTransform())
        mapper <<< owner               <-- ("owner", ToStringTransform())
        mapper <<< balance             <-- "balance"
        mapper <<< vestingPolicy      <-- "vesting_policy"
        mapper <<< lastClaimDate     <-- ("last_claim_date", ToStringTransform())
    }
}

class VestingPolicy: HandyJSON {
    var beginTimestamp: String = ""
    var vestingCliffSeconds: String = ""
    var vestingDurationSeconds: String = ""
    var beginBalance: String = ""

    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< beginTimestamp                <-- ("begin_timestamp", ToStringTransform())
        mapper <<< vestingCliffSeconds          <-- ("vesting_cliff_seconds", ToStringTransform())
        mapper <<< vestingDurationSeconds       <-- ("vesting_duration_seconds", ToStringTransform())
        mapper <<< beginBalance                  <-- ("begin_balance", ToStringTransform())
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

        icon = AppConfiguration.ServerIconsBaseURLString + balance.assetType.replacingOccurrences(of: ".", with: "_") + "_grey.png"
        // 获得自己的个数
        if let assetInfo = appData.assetInfo[balance.assetType] {
            realAmount = getRealAmount(balance.assetType, amount: balance.balance).string(digits: assetInfo.precision, roundingMode: .down)
            name = assetInfo.symbol.filterJade
        }

        // 获取对应CYB的个数
        let amountCYB = appData.cybRmbPrice == 0 ? "-" :  String(getAssetRMBPrice(balance.assetType) / appData.cybRmbPrice * (realAmount.toDouble())!)

        if amountCYB == "-"{
            cybPrice = amountCYB + " CYB"
        } else {
            cybPrice = amountCYB.formatCurrency(digitNum: 5) + " CYB"
        }

        if let _ = amountCYB.toDouble() {
            rbmPrice    = "≈¥" + (getRealAmount(balance.assetType, amount: balance.balance) * Decimal(getAssetRMBPrice(balance.assetType))).string(digits: 2, roundingMode: .down)
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
        icon = AppConfiguration.ServerIconsBaseURLString + balance.assetType.replacingOccurrences(of: ".", with: "_") + "_grey.png"

        name = appData.assetInfo[balance.assetType]?.symbol.filterJade ?? "--"
        // 获得自己的个数
        if let assetInfo = appData.assetInfo[balance.assetType] {
            realAmount = getRealAmount(balance.assetType, amount: balance.balance).string(digits: assetInfo.precision, roundingMode: .down)
        }

        // 获取对应CYB的个数
        let amountCYB = appData.cybRmbPrice == 0 ? "-" :  String(getAssetRMBPrice(balance.assetType) / appData.cybRmbPrice * (realAmount.toDouble())!)

//        let amountCYB = changeToETHAndCYB(balance.asset_type).cyb == "0" ? "-" :  String(changeToETHAndCYB(balance.asset_type).cyb.toDouble()! * (realAmount.toDouble())!)

        if let _ = amountCYB.toDouble() {
            rbmPrice = "≈¥" + (getRealAmount(balance.assetType, amount: balance.balance) * Decimal(getAssetRMBPrice(balance.assetType))).string(digits: 2, roundingMode: .down)
        } else {
            rbmPrice = "-"
        }

        //获取冻结资产
        var limitDecimal: Decimal = 0

        if let limitArray = UserManager.shared.limitOrder.value {
            for limit in limitArray {
                if limit.sellPrice.base.assetID == balance.assetType {
                    let amount = getRealAmount(balance.assetType, amount: limit.forSale)
                    limitDecimal += amount
                }
            }
            if let assetInfo = appData.assetInfo[balance.assetType] {
                if limitDecimal == 0 {
                    limitAmount = R.string.localizable.frozen.key.localized() + "--"
                } else {
                    log.debug("limitAmountlimitAmount\(limitDecimal.doubleValue)")
                    limitAmount = R.string.localizable.frozen.key.localized() + limitDecimal.string(digits: assetInfo.precision, roundingMode: .down)
                }
            }
        }
    }
}
