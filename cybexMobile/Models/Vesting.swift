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
            realAmount = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).formatCurrency(digitNum: assetInfo.precision)
            name = assetInfo.symbol.filterJade
        }

        // 获取对应CYB的个数
        let cybDecimal = AssetHelper.singleAssetRMBPrice(balance.assetType) / AssetConfiguration.shared.rmbOf(asset: .CYB) * realAmount.decimal()

        if AssetConfiguration.shared.rmbOf(asset: .CYB) == 0 {
            cybPrice = "- CYB"
            rbmPrice    = "-"
        } else {
            guard let cybInfo = appData.assetInfo[AssetConfiguration.CybexAsset.CYB.id] else { return }
            
            cybPrice = cybDecimal.formatCurrency(digitNum: cybInfo.precision) + " CYB"
            rbmPrice = "≈¥" + (AssetHelper.getRealAmount(balance.assetType,
                                                            amount: balance.balance) *
                AssetHelper.singleAssetRMBPrice(balance.assetType)).formatCurrency(digitNum: AppConfiguration.rmbPrecision)
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

        name = appData.assetInfo[balance.assetType]?.symbol.filterOnlyJade ?? "--"
        // 获得自己的个数
        if let assetInfo = appData.assetInfo[balance.assetType] {
            realAmount = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).formatCurrency(digitNum: assetInfo.precision)
        }

        if AssetConfiguration.shared.rmbOf(asset: .CYB) == 0 {
            rbmPrice = "-"

        } else {
            rbmPrice = "≈¥" + balance.rmbValue().formatCurrency(digitNum: 4)
        }

        //获取冻结资产
        var limitDecimal: Decimal = 0

        guard let orders = UserManager.shared.fullAccount.value?.limitOrders else {
            limitAmount = R.string.localizable.frozen.key.localized() + "--"
            return
        }

        for limitOrder in orders {
            if limitOrder.sellPrice.base.assetID == balance.assetType {
                let amount = AssetHelper.getRealAmount(balance.assetType, amount: limitOrder.forSale)
                limitDecimal += amount
            }
        }

        if let assetInfo = appData.assetInfo[balance.assetType] {
            if limitDecimal == 0 {
                limitAmount = R.string.localizable.frozen.key.localized() + "--"
            } else {
                limitAmount = R.string.localizable.frozen.key.localized() +
                    limitDecimal.formatCurrency(digitNum: assetInfo.precision)
            }
        }
    }
}
