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
import Guitar
import Repeat
import SwiftyUserDefaults
import cybex_ios_core_cpp
import HandyJSON

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

    func login(_ username: String, password: String) -> Promise<Void> {
        return unlock(username, password: password).done { fullaccount in
            self.saveUserInfo(username)
            self.loginType = .cloudWallet
            self.unlockType = .cloudPassword
            self.handlerFullAcount(fullaccount)
        }
    }

    func register(_ pinID: String, captcha: String, username: String, password: String) -> Promise<Void> {
        let (promise, seal) = Promise<Void>.pending()

        if let keys = generateAccountKeys(username, password: password) {

            RegisterService.request(target: .register(pinID, captcha: captcha, name: username, keys: keys), success: { (json) in
                if let code = json["code"].int { //失败
                    seal.reject(CybexError.tipError(.registerFail(code: code)))
                } else {
                    self.login(username, password: password).done {
                        seal.fulfill(())
                    }.catch({ (error) in
                        seal.reject(error)
                    })
                }
            }, error: { error in
                seal.reject(error)
            }) { error in
                seal.reject(error)
            }

        }
        else {
            seal.reject(CybexError.tipError(.unlockFail))
        }

        return promise
    }

    func logout() {
        Defaults.remove(.keys)
        Defaults.remove(.enotesKeys)
        self.keys = nil
        self.enotesKeys = nil
        self.loginType = .none
        self.unlockType = .none
        timer?.pause()
        timer = nil

        Defaults.remove(.username)
        Defaults.remove(.account)
        self.name.accept(nil)
        self.permission = AccountPermission()
        self.fullAccount.accept(nil)
    }

    func fetchAccountInfo(_ name: String) -> Promise<(FullAccount, Account)> {
        let (promise, seal) = Promise<(FullAccount, Account)>.pending()

        let request = GetFullAccountsRequest(name: name) { response in
            if let data = response as? FullAccount, let account = data.account {
                seal.fulfill((data, account))
            }
            else {
                seal.reject(CybexError.tipError(.userNotExist))
            }
        }
        CybexWebSocketService.shared.send(request: request)

        return promise
    }

    func checkPermission(_ keys: AccountKeys, account: Account) -> Bool {
        let permission = account.checkPermission([keys].compactMap({ $0 }))

        if permission.unlock {
            BitShareCoordinator.resetDefaultPublicKey(permission.defaultKey)
            self.timingLock()
            return true
        }

        return false
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

    func generateAccountKeys(_ username: String, password: String) -> AccountKeys? {
        BitShareCoordinator.cancelUserKey()
        let keysString = BitShareCoordinator.getUserKeys(username, password: password)
        return AccountKeys.deserialize(from: keysString)
    }

    func unlock(_ username: String?, password: String) -> Promise<FullAccount> {
        guard let name = username ?? self.name.value else {
            return Promise(error: CybexError.tipError(.userNotExist))
        }

        if let keys = generateAccountKeys(name, password: password) {
            let promise = fetchAccountInfo(name).map { (fullaccount, account) -> FullAccount in
                if self.checkPermission(keys, account: account) {
                    self.keys = keys
                    self.saveKeys()
                    return fullaccount
                }
                else {
                    throw CybexError.tipError(.unlockFail)
                }
            }

            return promise

        } else {
            return Promise(error: CybexError.tipError(.unlockFail))
        }

    }

    func getCachedKeysExcludePrivate() -> AccountKeys? {
        let keys = Defaults[.keys]
        return AccountKeys.deserialize(from: keys)
    }

    func getCachedEnotesKeysExcludePrivate() -> AccountKeys? {
        let keys = Defaults[.enotesKeys]
        return AccountKeys.deserialize(from: keys)
    }

    func getCachedAccount() -> Account? {
        let account = Defaults[.account]
        return Account.deserialize(from: account)
    }

    func updateAccount() {
        if let name = self.name.value {
            UserManager.shared.fetchAccountInfo(name).done({ (fullaccount, _) in
                self.handlerFullAcount(fullaccount)
            }).cauterize()
        }
    }

}

//eNotes
extension UserManager {
    func enotesLogin(_ pubKey: String) -> Promise<Void> {
        if let keys: AccountKeys = AccountKeys.deserialize(from: BitShareCoordinator.getActiveUserKeys(pubKey)) {
            let promise = CybexDatabaseApiService.request(target: .getKeyReferences(pubkey: pubKey)).then { (json) -> Promise<JSON>  in
                if let id = json[0][0].string {
                    return CybexDatabaseApiService.request(target: .getObjects(id: id))
                } else {
                    throw CybexError.tipError(.loginFail)
                }
            }.then { (json) -> Promise<Void> in
                if let name = json[0]["name"].string {
                    return self.fetchAccountInfo(name).map { (full, account) -> Void in
                        if account.activePubKeys.contains(pubKey) {
                            self.enotesKeys = keys
                            self.saveEnotesKeys()
                            self.saveUserInfo(name)
                            self.loginType = .nfc
                            self.unlockType = .nfc
                            self.timer?.pause()
                            self.timer = nil
                            self.handlerFullAcount(full)
                        } else {
                            throw CybexError.tipError(.loginFail)
                        }
                    }
                } else {
                    throw CybexError.tipError(.loginFail)
                }
            }

            return promise
        } else {
            return Promise(error: CybexError.tipError(.loginFail))
        }
    }

    func checkExistCloudPassword() -> Bool {
        if self.loginType == .nfc, let account = self.fullAccount.value, account.existMoreActiveKey() {
            return true
        }

        return false
    }
}

class UserManager {
    enum LoginType: Int { // 初始账号登录类型
        case none
        case cloudWallet
        case nfc
    }

    enum UnlockType: Int {
        case none
        case nfc
        case cloudPassword

        func description() -> String {
            switch self {
            case .cloudPassword: return R.string.localizable.enotes_unlock_type_1.key
            case .nfc: return R.string.localizable.enotes_unlock_type_0.key
            case .none: return ""
            }
        }
    }

    enum LockTime: Int, CaseIterable {
        case none
        case low = 300
        case middle = 1200
        case high = 3600

        func description() -> String {
            switch self {
            case .low: return R.string.localizable.lock_time.key.localizedFormat(5)
            case .middle: return R.string.localizable.lock_time.key.localizedFormat(20)
            case .high: return R.string.localizable.lock_time.key.localizedFormat(60)
            case .none: return ""
            }
        }
    }

    static let shared = UserManager()
    var disposeBag = DisposeBag()

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

    var loginType: LoginType = .none {
        didSet {
            Defaults[.loginType] = loginType.rawValue
        }
    }

    var lockTime: LockTime = .low {
        didSet {
            Defaults[.locktime] = lockTime.rawValue
            timingLock()
        }
    }

    var unlockType: UnlockType = .none {
        didSet {
            Defaults[.unlockType] = unlockType.rawValue
        }
    }

    var refreshTime: TimeInterval = 6 {
        didSet {
            appCoodinator.repeatFetchMarket(.veryLow)
        }
    }

    var isLocked: Bool {
        return self.keys == nil && unlockType == .cloudPassword
    }

    var logined: Bool {
        guard let name = name.value else {
            return false
        }

        return name.count > 0
    }

    var permission = AccountPermission()

    var name: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var avatarString: String? {
        return name.value?.sha256()
    }
    
    var timer: Repeater?
    private var keys: AccountKeys? { //云密码
        didSet {
            if keys == nil {
                BitShareCoordinator.cancelUserKey()
            }
        }
    }

    private var enotesKeys: AccountKeys? // enotes keys

    var fullAccount: BehaviorRelay<FullAccount?> = BehaviorRelay(value: nil)

    private init() {
        appData.otherRequestRelyData.asObservable()
            .subscribe(onNext: { (_) in
                DispatchQueue.main.async {
                    if MarketConfiguration.shared.marketPairs.value.count > 0 &&
                        !CybexWebSocketService.shared.overload() {
                        self.updateAccount()
                    }
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    func handlerFullAcount(_ data: FullAccount) {
        let fullaccount = data
        saveAccount(data.account)

        if let account = data.account {
            let keys = [getCachedKeysExcludePrivate(), getCachedEnotesKeysExcludePrivate()].compactMap({ $0 })
            if keys.count > 0 {
                let permission = account.checkPermission(keys)
                self.permission = permission
            }
        }

        fullaccount.balances = data.balances.filter({ (balance) -> Bool in
            let name = appData.assetInfo[balance.assetType]
            return name != nil
        })

        fullaccount.limitOrders = data.limitOrders.filter({ (limitOrder) -> Bool in
            let baseName = appData.assetInfo[limitOrder.sellPrice.base.assetID]
            let quoteName = appData.assetInfo[limitOrder.sellPrice.quote.assetID]
            let baseBool = baseName != nil
            let quoteBool = quoteName != nil
            return baseBool && quoteBool
        })

        fullaccount.calculateLimitOrderValue()
        fullaccount.calculateBalanceValue()
        fullAccount.accept(fullaccount)
    }

    func timingLock() {
        self.timer = Repeater.once(after: .seconds(self.lockTime.rawValue.double), {[weak self] (_) in
            guard let self = self else { return }
            self.keys = nil
        })
        timer?.start()
    }

    func saveUserInfo(_ username: String) {
        self.saveName(username)
        self.name.accept(username)
    }

    private func saveName(_ name: String) {
        Defaults[.username] = name
    }

    private func saveAccount(_ account: Account?) {
        guard let account = account else { return }
        Defaults[.account] = account.toJSONString() ?? ""
    }

    private func saveKeys() {
        guard let keys = keys else { return }
        keys.removePrivateKey()
        
        Defaults[.keys] = keys.toJSONString() ?? ""
    }

    private func saveEnotesKeys() {
        guard let keys = enotesKeys else { return }
        keys.removePrivateKey()

        Defaults[.enotesKeys] = keys.toJSONString() ?? ""
    }

}
