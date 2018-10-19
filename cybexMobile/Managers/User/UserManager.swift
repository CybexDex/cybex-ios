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
import KeychainAccess
import RxCocoa
import RxSwift
import PromiseKit
import AwaitKit
import Guitar
import Repeat
import SwiftyUserDefaults

extension UserManager {
    
    func validateUserName(_ username:String) -> (Bool, String) {
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
        
        return (true , "")
    }
    
    func login(_ username:String, password:String, completion:@escaping (Bool)->()) {
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
    
    func register(_ pinID:String, captcha:String, username:String, password:String) -> Promise<(Bool,Int)> {
        return async {
            let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
            
            if let keys = AccountKeys(JSONString: keysString), let active_key = keys.active_key, let owner_key = keys.owner_key, let memo_key = keys.memo_key {
                let params = ["cap":["id":pinID, "captcha":captcha], "account":["name":username, "owner_key":owner_key.public_key, "active_key":active_key.public_key,"memo_key":memo_key.public_key, "refcode":"", "referrer":""]]
                
                let data = try! await(SimpleHTTPService.requestRegister(params))
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
    
    func fetchAccountInfo(){
        if !isLoginIn {
            return
        }
        
        if let username = self.name.value {
            let request = GetFullAccountsRequest(name: username) { response in
                if let data = response as? FullAccount{
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
            if let data = data as? (fillOrders:[FillOrder],transferRecords:[TransferRecord]) {
                var fillorders = data.fillOrders
                if !self.isLoginIn {
                    return
                }
                if data.transferRecords.count == 0 {
                    self.transferRecords.accept(nil)
                }
                if fillorders.count == 0  {
                    self.fillOrder.accept(nil)
                }
                fillorders = fillorders.filter({
                    let base_name = app_data.assetInfo[$0.fill_price.base.assetID]
                    let quote_name = app_data.assetInfo[$0.fill_price.quote.assetID]
                    return base_name != nil && quote_name != nil
                })
                
                var result = [(FillOrder,time:String)]()
                var count = 0
                for fillOrder in fillorders{
                    let timeRequest = getBlockRequest(response: { (time) in
                        count += 1
                        if let time = time as? String, let date = time.dateFromISO8601{
                            result.append((fillOrder,time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
                        }
                        if count == fillorders.count{
                            self.fillOrder.accept(result)
                        }
                    }, block_num: fillOrder.block_num)
                    CybexWebSocketService.shared.send(request: timeRequest,priority: Operation.QueuePriority.high)
                }
                
                let transferRecordList = data.transferRecords
                if transferRecordList.count == 0 || !self.isLoginIn {
                    self.transferRecords.accept(nil)
                    return
                }
                
                var records = [(TransferRecord,time:String)]()
                var recordCount = 0
                for transferRecord in transferRecordList {
                    let timeRequest = getBlockRequest(response: { (time) in
                        recordCount += 1
                        if let time = time as? String, let date = time.dateFromISO8601{
                            records.append((transferRecord,time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
                        }
                        if recordCount == transferRecordList.count{
                            self.transferRecords.accept(records)
                        }
                    }, block_num: transferRecord.block_num)
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
                    let base_name = app_data.assetInfo[$0.fill_price.base.assetID]
                    let quote_name = app_data.assetInfo[$0.fill_price.quote.assetID]
                    return base_name != nil && quote_name != nil
                })
                
                var result = [(FillOrder,time:String)]()
                var count = 0
                for fillOrder in fillorders{
                    let timeRequest = getBlockRequest(response: { (time) in
                        count += 1
                        if let time = time as? String, let date = time.dateFromISO8601{
                            result.append((fillOrder,time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
                        }
                        if count == fillorders.count{
                            self.fillOrder.accept(result)
                        }
                    }, block_num: fillOrder.block_num)
                    CybexWebSocketService.shared.send(request: timeRequest)
                }
            }
        }
        CybexWebSocketService.shared.send(request: request)
    }
    
    func checkUserName(_ name:String) -> Promise<Bool> {
        let (promise,seal) = Promise<Bool>.pending()
        
        let request = GetAccountByNameRequest(name: name) { response in
            if let result = response as? Bool {
                seal.fulfill(result)
            }
            
        }
        
        CybexWebSocketService.shared.send(request: request)
        
        return promise
    }
    
    func unlock(_ username:String?, password:String, completion:@escaping (Bool, FullAccount?)->()) {
        guard let name = username ?? self.name.value else {
            completion(false, nil)
            return
        }
        
        let keysString = BitShareCoordinator.getUserKeys(name, password: password)!
        if let keys = AccountKeys(JSONString: keysString), let active_key = keys.active_key, let memoKey = keys.memo_key, let ownKey = keys.owner_key {
            var canLock = false
            
            let request = GetFullAccountsRequest(name: name) { response in
                if let data = response as? FullAccount, let account = data.account {
                    let active_auths = account.active_auths
                    let owner_auths = account.owner_auths
                    
                    for auth in active_auths {
                        if let auth = auth as? [Any], let key = auth[0] as? String {
                            if [memoKey.public_key, ownKey.public_key, active_key.public_key].contains(key) {
                                canLock = true
                                BitShareCoordinator.resetDefaultPublicKey(key)
                                break
                            }
                        }
                    }
                    
                    if !canLock {
                        for auth in owner_auths {
                            if let auth = auth as? [Any], let key = auth[0] as? String {
                                if [memoKey.public_key, ownKey.public_key, active_key.public_key].contains(key) {
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
                            if let memoKey = keys.memo_key, let ownKey = keys.owner_key, let activeKey = keys.active_key {
                                if [memoKey.public_key, ownKey.public_key, activeKey.public_key].contains(newAccount.memo_key) {
                                    self.isWithDraw = true
                                }
                            }
                            if let memoKey = keys.memo_key, let ownKey = keys.owner_key, let activeKey = keys.active_key{
                                if let activeKeys = newAccount.active_auths as? [String]{
                                    for activekey in activeKeys{
                                        if [memoKey.public_key, ownKey.public_key, activeKey.public_key].contains(activekey){
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
        }
            
        else{
            completion(false, nil)
        }
        
    }
    
    func handlerFullAcount(_ data:FullAccount) {
        self.account.accept(data.account)
        
        if let balances = data.balances {
            self.balances.accept(balances.filter({ (balance) -> Bool in
                let name = app_data.assetInfo[balance.asset_type]
                return (name != nil) && ((name?.symbol.hasPrefix("JADE"))! ||  name?.symbol == "CYB")
                //        return getRealAmount(balance.asset_type, amount: balance.balance) != 0 &&
                //          (name != nil) && ((name?.symbol.hasPrefix("JADE"))! ||  name?.symbol == "CYB")
            }))
            
        }else{
            self.balances.accept(data.balances)
        }
        
        if let limitOrders = data.limitOrder {
            self.limitOrder.accept(limitOrders.filter({ (limitOrder) -> Bool in
                let base_name = app_data.assetInfo[limitOrder.sellPrice.base.assetID]
                let quote_name = app_data.assetInfo[limitOrder.sellPrice.quote.assetID]
                let base_bool = base_name != nil && ((base_name?.symbol.hasPrefix("JADE"))! || base_name?.symbol == "CYB")
                let quote_bool = quote_name != nil && ((quote_name?.symbol.hasPrefix("JADE"))! || quote_name?.symbol == "CYB")
                
                return base_bool && quote_bool
            }))
        }else{
            self.limitOrder.accept(data.limitOrder)
        }
    }
    
}

class UserManager {
    static let shared = UserManager()
    var disposeBag = DisposeBag()
    
    var isLoginIn : Bool {
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
    
    enum frequency_type : Int{
        case normal = 0
        case time
        case WiFi
        
        func description() -> String {
            switch self {
            case .normal:return R.string.localizable.frequency_normal.key
            case .time:return R.string.localizable.frequency_time.key
            case .WiFi:return R.string.localizable.frequency_wifi.key
            }
        }
    }
    
    var isLocked:Bool {
        return self.keys == nil
    }
    
    var frequency_type : frequency_type = .WiFi {
        didSet {
            Defaults[.frequency_type] = self.frequency_type.rawValue
            switch self.frequency_type {
            case .normal:self.refreshTime = 6
            case .time:self.refreshTime = 3
            case .WiFi:
                let status = reachability.connection
                if status == .wifi {
                    self.refreshTime = 3
                }else {
                    self.refreshTime = 6
                }
            }
        }
    }
    
    var refreshTime : TimeInterval = 6 {
        didSet {
            app_coodinator.repeatFetchPairInfo(.veryLow)
        }
    }
    var isWithDraw : Bool = false
    var isTrade : Bool = false
    var name : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var keys:AccountKeys?
    var avatarString:String?
    var account:BehaviorRelay<Account?> = BehaviorRelay(value: nil)
    
    var balances:BehaviorRelay<[Balance]?> = BehaviorRelay(value: nil)
    var limitOrder:BehaviorRelay<[LimitOrder]?> = BehaviorRelay(value:nil)
    var fillOrder:BehaviorRelay<[(FillOrder,time:String)]?> = BehaviorRelay(value:nil)
    var transferRecords : BehaviorRelay<[(TransferRecord,time:String)]?> = BehaviorRelay(value: nil)
    
    var timer:Repeater?
    
    var limitOrderValue: Double {
        var _limitOrderValue: Decimal = 0
//        var _limitOrder_buy_value:Double = 0
        if let limitOrder = limitOrder.value{
            for limitOrder_value in limitOrder{
                
//                let assetA_info = app_data.assetInfo[limitOrder_value.sellPrice.base.assetID]
//                let assetB_info = app_data.assetInfo[limitOrder_value.sellPrice.quote.assetID]
                
//                let (base,_) = calculateAssetRelation(assetID_A_name: (assetA_info != nil) ? assetA_info!.symbol.filterJade : "", assetID_B_name: (assetB_info != nil) ? assetB_info!.symbol.filterJade : "")
//                let isBuy = base == ((assetA_info != nil) ? assetA_info!.symbol.filterJade : "")
                
                let realAmount = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale)
                let price_value = getAssetRMBPrice(limitOrder_value.sellPrice.base.assetID)
                _limitOrderValue += realAmount * Decimal(price_value)
                
//                if isBuy {
//                    let realAmount = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale)
//                    let price_value = getAssetRMBPrice(limitOrder_value.sellPrice.base.assetID)
//                    _limitOrderValue += realAmount * Decimal(price_value)
                
//                    if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
//                        let buy_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale).doubleValue * eth_cyb
//                        _limitOrderValue += buy_value
////                        _limitOrder_buy_value += buy_value
//                    }
//                }
//                else{
                
//                    if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
//                        let sell_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale).doubleValue * eth_cyb
//                        _limitOrderValue += sell_value
//                    }
//                }
            }
        }
        
        return _limitOrderValue.doubleValue
    }
    
    var limitOrder_buy_value: Double = 0
    
    var limit_reset_address_time : TimeInterval = 0
    
    var balance : Double {
        
        var balance_values: Decimal = 0
        var _limitOrderValue: Decimal = 0
        var _limitOrder_buy_value: Decimal = 0
        
        if let balances = balances.value {
            for balance_value in balances{
                let realAmount = getRealAmount(balance_value.asset_type,amount: balance_value.balance)
                let real_rmb_price = getAssetRMBPrice(balance_value.asset_type)
                balance_values += realAmount * Decimal(real_rmb_price)
                
//                if let eth_cyb = changeToETHAndCYB(balance_value.asset_type).cyb.toDouble() {
//                    balance_values += getRealAmount(balance_value.asset_type,amount: balance_value.balance).doubleValue * eth_cyb
//                }
            }
        }
        
        if let limitOrder = limitOrder.value{
            for limitOrder_value in limitOrder{
                let assetA_info = app_data.assetInfo[limitOrder_value.sellPrice.base.assetID]
                let assetB_info = app_data.assetInfo[limitOrder_value.sellPrice.quote.assetID]
                
                let (base,_) = calculateAssetRelation(assetID_A_name: (assetA_info != nil) ? assetA_info!.symbol.filterJade : "", assetID_B_name: (assetB_info != nil) ? assetB_info!.symbol.filterJade : "")
                let isBuy = base == ((assetA_info != nil) ? assetA_info!.symbol.filterJade : "")
                
                let realAmount = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale)
                let price_value = getAssetRMBPrice(limitOrder_value.sellPrice.base.assetID)
                _limitOrderValue += realAmount * Decimal(price_value)
                balance_values += _limitOrderValue
                if isBuy {
                    _limitOrder_buy_value += _limitOrderValue
                }
                
//                if isBuy {
//                    if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
//                        let buy_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale).doubleValue * eth_cyb
//                        _limitOrderValue += buy_value
//                        _limitOrder_buy_value += buy_value
//                        balance_values += buy_value
//                    }
//                }
//                else{
//                    if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
//                        let sell_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale).doubleValue * eth_cyb
//                        _limitOrderValue += sell_value
//                        balance_values += sell_value
//                    }
//                }
            }
        }
        
        //    limitOrderValue = _limitOrderValue
        limitOrder_buy_value = _limitOrder_buy_value.doubleValue
        
        return balance_values.doubleValue
    }
    
    func timingLock() {
        self.timer = Repeater.once(after: .seconds(300), {[weak self] (timer) in
            guard let `self` = self else { return }
            self.keys = nil
        })
        
        timer?.start()
    }
    
    private init() {
        
        app_data.otherRequestRelyData.asObservable()
            .subscribe(onNext: { (s) in
                DispatchQueue.main.async {
                    if UserManager.shared.isLoginIn && AssetConfiguration.shared.asset_ids.count > 0 && !CybexWebSocketService.shared.overload() {
                        UserManager.shared.fetchAccountInfo()
                    }
                    
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        account.asObservable().skip(1).subscribe(onNext: {[weak self] (newAccount) in
            guard let `self` = self else { return }
            if CybexWebSocketService.shared.overload() || self.fillOrder.value != nil {
                return
            }
            self.fetchHistoryOfFillOrdersAndTransferRecords()
        }).disposed(by: disposeBag)
        
    }
    
    private func saveName(_ name:String) {
        Defaults[.username] = name
    }
    
    func getPortfolioDatas() -> [PortfolioData]{
        var datas = [PortfolioData]()
        if let balances = self.balances.value{
            for balance in balances{
                datas.append(PortfolioData.init(balance: balance)!)
            }
        }
        return datas
    }
    
    func getMyPortfolioDatas() -> [MyPortfolioData]{
        var datas = [MyPortfolioData]()
        if let balances = self.balances.value {
            for balance in balances{
                if let foloiData = MyPortfolioData.init(balance: balance) {
                    if (foloiData.realAmount == "" || foloiData.realAmount.toDouble() == 0) && foloiData.limitAmount.contains("--") {
                        
                    }
                    else {
                        datas.append(foloiData)
                    }
                }
            }
        }
        return datas
    }
}


