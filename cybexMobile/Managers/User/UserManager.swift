//
//  UserManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import CryptoSwift
import RxCocoa
import RxSwift
import PromiseKit
import AwaitKit
import Guitar
import Repeat
import SwiftyUserDefaults
import cybex_ios_core_cpp

extension UserManager {

    func validateUserName(_ username: String) -> (Bool, String) {
        let letterBegin = Guitar(pattern: "^([a-z])")
        if !letterBegin.test(string: username) {
            return (false, R.string.localizable.accountValidateError2.key.localized())
        }

        let legal = Guitar(pattern: "([^a-z0-9\\-])")
        if legal.test(string: username) {
            return (false, R.string.localizable.accountValidateError6.key.localized())
        }

        if username.count > 63 || username.count < 3 {
            return (false, R.string.localizable.accountValidateError3.key.localized())
        }

        let containOther = Guitar(pattern: "[0-9+|\\-+]")
        let continuousDashes = Guitar(pattern: "(\\-\\-)")
        let dashEnd = Guitar(pattern: "(\\-)$")

        if !containOther.test(string: username) {
            return (false, R.string.localizable.accountValidateError4.key.localized())
        }

        if continuousDashes.test(string: username) {
            return (false, R.string.localizable.accountValidateError5.key.localized())
        }

        if dashEnd.test(string: username) {
            return (false, R.string.localizable.accountValidateError7.key.localized())
        }

        return (true, "")
    }

    func login(_ username: String, password: String, completion:@escaping (Bool)->Void) {
        self.unlock(username, password: password) {[weak self] (locked, data) in
            guard let `self` = self else { return }
            if locked {
                self.saveName(username)
                self.avatarString = username.sha256()

                self.name.accept(username)
                self.handlerFullAcount(data!)
            }

            completion(locked)
        }
    }

    func register(_ pinID: String, captcha: String, username: String, password: String) -> Promise<(Bool, Int)> {
        return async {
            let keysString = BitShareCoordinator.getUserKeys(username, password: password)!

            if let keys = AccountKeys.deserialize(from: keysString),
                let activeKey = keys.activeKey,
                let ownerKey = keys.ownerKey,
                let memoKey = keys.memoKey {
                let params = ["cap": ["id": pinID, "captcha": captcha],
                              "account": ["name": username,
                                          "owner_key": ownerKey.publicKey,
                                          "active_key": activeKey.publicKey,
                                          "memo_key": memoKey.publicKey,
                                          "refcode": "",
                                          "referrer": ""]]
                guard let data = try? await(SimpleHTTPService.requestRegister(params)) else {
                    return (false, 0)
                }

                if data.0 {
                    self.saveName(username)
                    self.avatarString = username.sha256()

                    self.name.accept(username)

                    self.keys = keys
                    self.fetchAccountInfo()
                }
                return data

            }
            return (false, 0)
        }
    }

    func logout() {
        BitShareCoordinator.cancelUserKey()

        Defaults.remove(.username)

        self.name.accept(nil)
        self.avatarString = nil
        self.keys = nil
        self.account.accept(nil)
        self.balances.accept(nil)
        self.limitOrder.accept(nil)
        self.fillOrder.accept(nil)
        self.transferRecords.accept(nil)
    }

    func fetchAccountInfo() {
        if !isLoginIn {
            return
        }

        if let username = self.name.value {
            let request = GetFullAccountsRequest(name: username) { response in
                if let data = response as? FullAccount {
                    if !self.isLoginIn {
                        return
                    }

                    self.handlerFullAcount(data)
                }
            }
            CybexWebSocketService.shared.send(request: request)
        }
    }

    func fetchHistoryOfFillOrdersAndTransferRecords() {
        guard let id = self.account.value?.id else {
            return
        }

        let request = GetAccountHistoryRequest(accountID: id) { (data) in
            if let data = data as? (fillOrders: [FillOrder], transferRecords: [TransferRecord]) {
                var fillorders = data.fillOrders
                if !self.isLoginIn {
                    return
                }
                if data.transferRecords.count == 0 {
                    self.transferRecords.accept(nil)
                }
                if fillorders.count == 0 {
                    self.fillOrder.accept(nil)
                }
                fillorders = fillorders.filter({
                    let baseName = appData.assetInfo[$0.fillPrice.base.assetID]
                    let quoteName = appData.assetInfo[$0.fillPrice.quote.assetID]
                    return baseName != nil && quoteName != nil
                })

                var result = [(FillOrder, time:String)]()
                var count = 0
                for fillOrder in fillorders {
                    let timeRequest = GetBlockRequest(response: { (time) in
                        count += 1
                        if let time = time as? String, let date = time.dateFromISO8601 {
                            result.append((fillOrder, time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
                        }
                        if count == fillorders.count {
                            self.fillOrder.accept(result)
                        }
                    }, blockNum: fillOrder.blockNum)
                    CybexWebSocketService.shared.send(request: timeRequest, priority: Operation.QueuePriority.high)
                }

                let transferRecordList = data.transferRecords
                if transferRecordList.count == 0 || !self.isLoginIn {
                    self.transferRecords.accept(nil)
                    return
                }

                var records = [(TransferRecord, time:String)]()
                var recordCount = 0
                for transferRecord in transferRecordList {
                    let timeRequest = GetBlockRequest(response: { (time) in
                        recordCount += 1
                        if let time = time as? String, let date = time.dateFromISO8601 {
                            records.append((transferRecord, time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
                        }
                        if recordCount == transferRecordList.count {
                            self.transferRecords.accept(records)
                        }
                    }, blockNum: transferRecord.blockNum)
                    CybexWebSocketService.shared.send(request: timeRequest)
                }
            }

        }
        CybexWebSocketService.shared.send(request: request)
    }

    func fetchHistoryOfOperation() {
        guard let id = self.account.value?.id else {
            return
        }

        let request = GetAccountHistoryRequest(accountID: id) { (data) in

            if var fillorders = data as? [FillOrder] {
                if fillorders.count == 0 || !self.isLoginIn {
                    self.fillOrder.accept(nil)
                    return
                }
                fillorders = fillorders.filter({
                    let baseName = appData.assetInfo[$0.fillPrice.base.assetID]
                    let quoteName = appData.assetInfo[$0.fillPrice.quote.assetID]
                    return baseName != nil && quoteName != nil
                })

                var result = [(FillOrder, time:String)]()
                var count = 0
                for fillOrder in fillorders {
                    let timeRequest = GetBlockRequest(response: { (time) in
                        count += 1
                        if let time = time as? String, let date = time.dateFromISO8601 {
                            result.append((fillOrder, time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
                        }
                        if count == fillorders.count {
                            self.fillOrder.accept(result)
                        }
                    }, blockNum: fillOrder.blockNum)
                    CybexWebSocketService.shared.send(request: timeRequest)
                }
            }
        }
        CybexWebSocketService.shared.send(request: request)
    }

    func checkUserName(_ name: String) -> Promise<Bool> {
        let (promise, seal) = Promise<Bool>.pending()

        let request = GetAccountByNameRequest(name: name) { response in
            if let result = response as? Bool {
                seal.fulfill(result)
            }

        }

        CybexWebSocketService.shared.send(request: request)

        return promise
    }

    func unlock(_ username: String?, password: String, completion:@escaping (Bool, FullAccount?)->Void) {
        guard let name = username ?? self.name.value else {
            completion(false, nil)
            return
        }

        let keysString = BitShareCoordinator.getUserKeys(name, password: password)!
        if let keys = AccountKeys.deserialize(from: keysString),
            let activeKey = keys.activeKey,
            let memoKey = keys.memoKey,
            let ownKey = keys.ownerKey {
            var canLock = false

            let request = GetFullAccountsRequest(name: name) { response in
                if let data = response as? FullAccount, let account = data.account {
                    let activeAuths = account.activeAuths
                    let ownerAuths = account.ownerAuths

                    for auth in activeAuths {
                        if let auth = auth as? [Any], let key = auth[0] as? String {
                            if [memoKey.publicKey, ownKey.publicKey, activeKey.publicKey].contains(key) {
                                canLock = true
                                BitShareCoordinator.resetDefaultPublicKey(key)
                                break
                            }
                        }
                    }

                    if !canLock {
                        for auth in ownerAuths {
                            if let auth = auth as? [Any], let key = auth[0] as? String {
                                if [memoKey.publicKey, ownKey.publicKey, activeKey.publicKey].contains(key) {
                                    canLock = true
                                    BitShareCoordinator.resetDefaultPublicKey(key)
                                    break
                                }
                            }
                        }
                    }

                    if canLock {
                        self.keys = keys

                        if let newAccount = data.account {
                            if let memoKey = keys.memoKey, let ownKey = keys.ownerKey, let activeKey = keys.activeKey {
                                if [memoKey.publicKey, ownKey.publicKey, activeKey.publicKey].contains(newAccount.memoKey) {
                                    self.isWithDraw = true
                                }
                            }
                            if let memoKey = keys.memoKey, let ownKey = keys.ownerKey, let activeKey = keys.activeKey {
                                if let activeKeys = newAccount.activeAuths as? [String] {
                                    for activekey in activeKeys {
                                        if [memoKey.publicKey, ownKey.publicKey, activeKey.publicKey].contains(activekey) {
                                            self.isTrade = true
                                        }
                                    }
                                }
                            }
                        }

                        completion(true, data)
                        self.timingLock()
                        return
                    }
                }
                completion(false, nil)
            }
            CybexWebSocketService.shared.send(request: request)
        } else {
            completion(false, nil)
        }

    }

    func handlerFullAcount(_ data: FullAccount) {
        self.account.accept(data.account)

        if let balances = data.balances {
            self.balances.accept(balances.filter({ (balance) -> Bool in
                let name = appData.assetInfo[balance.assetType]
                return name != nil
//                return (name != nil) && ((name?.symbol.hasPrefix("JADE"))! ||  name?.symbol == "CYB")
                //        return getRealAmount(balance.asset_type, amount: balance.balance) != 0 &&
                //          (name != nil) && ((name?.symbol.hasPrefix("JADE"))! ||  name?.symbol == "CYB")
            }))

        } else {
            self.balances.accept(data.balances)
        }

        if let limitOrders = data.limitOrder {
            self.limitOrder.accept(limitOrders.filter({ (limitOrder) -> Bool in
                let baseName = appData.assetInfo[limitOrder.sellPrice.base.assetID]
                let quoteName = appData.assetInfo[limitOrder.sellPrice.quote.assetID]
                let baseBool = baseName != nil
                let quoteBool = quoteName != nil

//                let base_bool = base_name != nil && ((base_name?.symbol.hasPrefix("JADE"))! || base_name?.symbol == "CYB")
//                let quote_bool = quote_name != nil && ((quote_name?.symbol.hasPrefix("JADE"))! || quote_name?.symbol == "CYB")

                return baseBool && quoteBool
            }))
        } else {
            self.limitOrder.accept(data.limitOrder)
        }
    }

}

class UserManager {
    static let shared = UserManager()
    var disposeBag = DisposeBag()

    var isLoginIn: Bool {
        let name = Defaults[.username]
        if name.count > 0 {
            if self.name.value == nil {
                self.name.accept(name)
                self.avatarString = name.sha256()
            }

            return true
        }
        return false
    }

    enum FrequencyType: Int {
        case normal = 0
        case time
        case wiFi

        func description() -> String {
            switch self {
            case .normal:return R.string.localizable.frequency_normal.key
            case .time:return R.string.localizable.frequency_time.key
            case .wiFi:return R.string.localizable.frequency_wifi.key
            }
        }
    }

    var isLocked: Bool {
        return self.keys == nil
    }

    var frequencyType: FrequencyType = .wiFi {
        didSet {
            Defaults[.frequencyType] = self.frequencyType.rawValue
            switch self.frequencyType {
            case .normal:self.refreshTime = 6
            case .time:self.refreshTime = 3
            case .wiFi:
                let status = reachability.connection
                if status == .wifi {
                    self.refreshTime = 3
                } else {
                    self.refreshTime = 6
                }
            }
        }
    }

    var refreshTime: TimeInterval = 6 {
        didSet {
            appCoodinator.repeatFetchPairInfo(.veryLow)
        }
    }
    var isWithDraw: Bool = false
    var isTrade: Bool = false
    var name: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var keys: AccountKeys?
    var avatarString: String?
    var account: BehaviorRelay<Account?> = BehaviorRelay(value: nil)

    var balances: BehaviorRelay<[Balance]?> = BehaviorRelay(value: nil)
    var limitOrder: BehaviorRelay<[LimitOrder]?> = BehaviorRelay(value: nil)
    var fillOrder: BehaviorRelay<[(FillOrder, time: String)]?> = BehaviorRelay(value: nil)
    var transferRecords: BehaviorRelay<[(TransferRecord, time: String)]?> = BehaviorRelay(value: nil)

    var timer: Repeater?

    var limitOrderValue: Double {
        var decimallimitOrderValue: Decimal = 0
        //        var _limitOrder_buy_value:Double = 0
        if let limitOrder = limitOrder.value {
            for limitOrderValue in limitOrder {
                let realAmount = getRealAmount(limitOrderValue.sellPrice.base.assetID, amount: limitOrderValue.forSale)
                let priceValue = getAssetRMBPrice(limitOrderValue.sellPrice.base.assetID)
                decimallimitOrderValue += (realAmount * Decimal(priceValue))
            }
        }
        return decimallimitOrderValue.doubleValue
    }

    var limitOrderBuyValue: Double = 0

    var limitOrderSellValue: Double = 0

    var limitResetAddressTime: TimeInterval = 0

    var balance: Double {

        var balanceValues: Decimal = 0
        var decimallimitOrderValue: Decimal = 0
        var decimallimitOrderBuyValue: Decimal = 0
        var decimallimitOrderSellValue: Decimal = 0
        if let balances = balances.value {
            for balanceValue in balances {
                let realAmount = getRealAmount(balanceValue.assetType, amount: balanceValue.balance)
                let realRMBPrice = getAssetRMBPrice(balanceValue.assetType)
                balanceValues += realAmount * Decimal(realRMBPrice)
            }
        }

        if let limitOrder = limitOrder.value {
            for limitOrderValue in limitOrder {
                let assetAInfo = appData.assetInfo[limitOrderValue.sellPrice.base.assetID]
                let assetBInfo = appData.assetInfo[limitOrderValue.sellPrice.quote.assetID]

                let (base, _) = calculateAssetRelation(assetIDAName: (assetAInfo != nil) ? assetAInfo!.symbol.filterJade : "", assetIDBName: (assetBInfo != nil) ? assetBInfo!.symbol.filterJade : "")
                let isBuy = base == ((assetAInfo != nil) ? assetAInfo!.symbol.filterJade : "")

                let realAmount = getRealAmount(limitOrderValue.sellPrice.base.assetID, amount: limitOrderValue.forSale)
                let priceValue = getAssetRMBPrice(limitOrderValue.sellPrice.base.assetID)
                decimallimitOrderValue += realAmount * Decimal(priceValue)
                balanceValues += decimallimitOrderValue
                if isBuy {
                    decimallimitOrderBuyValue += realAmount * Decimal(priceValue)
                } else {
                    decimallimitOrderSellValue += realAmount * Decimal(priceValue)
                }
            }
        }

        //    limitOrderValue = _limitOrderValue
        limitOrderBuyValue = decimallimitOrderBuyValue.doubleValue
        limitOrderSellValue = decimallimitOrderSellValue.doubleValue
        return balanceValues.doubleValue
    }

    func timingLock() {
        self.timer = Repeater.once(after: .seconds(300), {[weak self] (_) in
            guard let `self` = self else { return }
            self.keys = nil
        })

        timer?.start()
    }

    private init() {

        appData.otherRequestRelyData.asObservable()
            .subscribe(onNext: { (_) in
                DispatchQueue.main.async {
                    if UserManager.shared.isLoginIn && AssetConfiguration.shared.assetIds.count > 0 && !CybexWebSocketService.shared.overload() {
                        UserManager.shared.fetchAccountInfo()
                    }

                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        account.asObservable().skip(1).subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            if CybexWebSocketService.shared.overload() || self.fillOrder.value != nil {
                return
            }
            self.fetchHistoryOfFillOrdersAndTransferRecords()
        }).disposed(by: disposeBag)

    }

    private func saveName(_ name: String) {
        Defaults[.username] = name
    }

    func getPortfolioDatas() -> [PortfolioData] {
        var datas = [PortfolioData]()
        if let balances = self.balances.value {
            for balance in balances {
                datas.append(PortfolioData.init(balance: balance)!)
            }
        }
        return datas
    }

    func getMyPortfolioDatas() -> [MyPortfolioData] {
        var datas = [MyPortfolioData]()
        if let balances = self.balances.value {
            for balance in balances {
                if let foloiData = MyPortfolioData.init(balance: balance) {
                    if (foloiData.realAmount == "" || foloiData.realAmount.toDouble() == 0) && foloiData.limitAmount.contains("--") {

                    } else {
                        datas.append(foloiData)
                    }
                }
            }
        }
        return datas
    }
}
