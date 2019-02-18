//
//  Constants.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension Notification.Name {
    static let NetWorkChanged = Notification.Name(rawValue: "NetWorkChanged") //授权网络状态切换
}

enum FundType: String {
    case WITHDRAW
    case DEPOSIT
    case ALL = ""
}

enum ChainTypesOperations: Int {
    case transfer = 0
    case limitOrderCreate
    case limitOrderCancel
    case callOrderUpdate
    case fillOrder
    case accountCreate
    case accountUpdate
    case accountWhitelist
    case accountUpgrade
    case accountTransfer
    case assetCreate
    case assetUpdate
    case assetUpdateBitasset
    case assetUpdateFeedProducers
    case assetIssue
    case assetReserve
    case assetFundFeePool
    case assetSettle
    case assetGlobalSettle
    case assetPublishFeed
    case witnessCreate
    case witnessUpdate
    case proposalCreate
    case proposalUpdate
    case proposalDelete
    case withdrawPermissionCreate
    case withdrawPermissionUpdate
    case withdrawPermissionClaim
    case withdrawPermissionDelete
    case committeeMemberCreate
    case committeeMemberUpdate
    case committeeMemberUpdateGlobalParameters
    case vestingBalanceCreate
    case vestingBalanceWithdraw
    case workerCreate
    case custom
    case assert
    case balanceClaim
    case overrideTransfer
    case transferToBlind
    case blindTransfer
    case transferFromBlind
    case assetSettleCancel
    case assetClaimFees
    case fbaDistribute
    case initiateCrowdfund
    case participateCrowdfund
    case withdrawCrowdfund
    case fillCrowdfund
    case cancelVesting
    case bidCollateral
    case executeBid
    case cancelAll
    case initiateDiceBet
    case depositDiceBet
    case withdrawDiceBet
    case participateDiceBet
    case diceBetClearing
}

enum ObjectID: String {
    case baseObject = "1.1.0"
    case accountObject = "1.2.0"
    case assetObject = "1.3.0"
    case forceSettlementObject = "1.4.0"
    case committeeMemberObject = "1.5.0"
    case witnessObject = "1.6.0"
    case limitOrderObject = "1.7.0"
    case callOrderObject = "1.8.0"
    case customObject = "1.9.0"
    case proposalObject = "1.10.0"
    case operationHistoryObject = "1.11.0"
    case withdrawPermissionObject = "1.12.0"
    case vestingBalanceObject = "1.13.0"
    case workerObject = "1.14.0"
    case balanceObject = "1.15.0"
    case globalPropertyObject = "2.0.0"
    case dynamicGlobalPropertyObject = "2.1.0"
    case assetDynamicData = "2.3.0"
    case assetDitassetData = "2.4.0"
    case accountBalanceObject = "2.5.0"
    case accountStatisticsObject = "2.6.0"
    case transactionObject = "2.7.0"
    case blockSummaryObject = "2.8.0"
    case accountTransactionHistoryObject = "2.9.0"
    case blindedBalanceObject = "2.10.0"
    case chainPropertyObject = "2.11.0"
    case witnessScheduleObject = "2.12.0"
    case budgetRecordObject = "2.13.0"
    case specialAuthorityObject = "2.14.0"
}


