//
//  Account.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct AccountPermission: HandyJSON {
    var unlock: Bool = false
    var defaultKey: String = ""
    var withdraw: Bool = false
    var trade: Bool = false
}

class FullAccount: HandyJSON {
    var account: Account?
    var balances: [Balance] = []
    var limitOrders: [LimitOrder] = []

    //rmb value
    var limitOrderValue: Decimal = 0
    var limitOrderBuyValue: Decimal = 0
    var limitOrderSellValue: Decimal = 0
    var balance: Decimal = 0

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<< limitOrders <-- "limit_orders"
    }

    func existMoreActiveKey() -> Bool {
        guard let account = account else { return false }
        return account.activePubKeys.count > 1
    }

    func calculateLimitOrderValue() {
        var decimallimitOrderValue: Decimal = 0
        var decimalBuylimitOrderValue: Decimal = 0
        var decimalSelllimitOrderValue: Decimal = 0

        for limitOrderValue in limitOrders {
            let value = limitOrderValue.rmbValue()
            decimallimitOrderValue += value

            if limitOrderValue.isBuy {
                decimalBuylimitOrderValue += value
            } else {
                decimalSelllimitOrderValue += value
            }
        }

        limitOrderValue = decimallimitOrderValue
        limitOrderBuyValue = decimalBuylimitOrderValue
        limitOrderSellValue = decimalSelllimitOrderValue
    }


    func calculateBalanceValue() {
        var balanceValues: Decimal = 0

        for balanceValue in balances {
            balanceValues += balanceValue.rmbValue()
        }

        balanceValues += limitOrderValue

        balance = balanceValues
    }

}

class Account: HandyJSON {
    var membershipExpirationDate: String = ""
    var name: String = ""
    var activeAuths: [Any] = []
    var ownerAuths: [Any] = []
    var memoKey: String = ""
    var id: String = ""

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<<
            membershipExpirationDate <-- ("membership_expiration_date", ToStringTransform())
        mapper <<< name <-- ("name", ToStringTransform())
        mapper <<< activeAuths <-- ["active_keys_auths", "active.key_auths"]
        mapper <<< ownerAuths <-- ["owner_keys_auths", "owner.key_auths"]
        mapper <<< id <-- "id"
        mapper <<< memoKey <-- ["memo_key", "options.memo_key"]
    }

    var activePubKeys: [String] {
        guard let auths = activeAuths as? [[Any]] else { return [] }
        guard let mapsResult = auths.map({$0[0]}) as? [String] else { return [] }

        return mapsResult
    }

    var ownerPubKeys: [String] {
        guard let auths = ownerAuths as? [[Any]] else { return [] }
        guard let mapsResult = auths.map({$0[0]}) as? [String] else { return [] }

        return mapsResult
    }

    var allPubKeys: [String] {
        return activePubKeys + ownerPubKeys
    }

    func checkPermission(_ keys: [AccountKeys]) -> AccountPermission {
        var permission = AccountPermission()

        var canUnlock = false

        let allKeys = keys.reduce([], { $0 + $1.pubKeys }).removingDuplicates()

        for key in allPubKeys {
            if allKeys.contains(key) {
                canUnlock = true
                permission.defaultKey = key
                break
            }
        }

        let canTrade = allKeys.contains(where: { (key) -> Bool in
            return activePubKeys.contains(key)
        })

        permission.unlock = canUnlock
        permission.withdraw = allKeys.contains(memoKey)
        permission.trade = canTrade

        return permission
    }
}

extension Account {
    var superMember: Bool {
        let second = membershipExpirationDate.dateFromISO8601?.timeIntervalSince1970 ?? 1

        return second < 0
    }
}


func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601)
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}

// MARK: - Htlc
class Htlc: Codable {
    let id: String
    let transfer: TransferObject
    let conditions: Conditions
    var isExpanded: Bool = false
    var from: String = ""
    var to: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        case transfer
        case conditions
    }

    init(id: String, transfer: TransferObject, conditions: Conditions) {
        self.id = id
        self.transfer = transfer
        self.conditions = conditions
    }

}

// MARK: Htlc convenience initializers and mutators

extension Htlc {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Htlc.self, from: data)
        self.init(id: me.id, transfer: me.transfer, conditions: me.conditions)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        id: String? = nil,
        transfer: TransferObject? = nil,
        conditions: Conditions? = nil
        ) -> Htlc {
        return Htlc(
            id: id ?? self.id,
            transfer: transfer ?? self.transfer,
            conditions: conditions ?? self.conditions
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Conditions
class Conditions: Codable {
    let timeLock: TimeLock
    let hashLock: HashLock

    init(timeLock: TimeLock, hashLock: HashLock) {
        self.timeLock = timeLock
        self.hashLock = hashLock
    }
}

// MARK: Conditions convenience initializers and mutators

extension Conditions {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(Conditions.self, from: data)
        self.init(timeLock: me.timeLock, hashLock: me.hashLock)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        timeLock: TimeLock? = nil,
        hashLock: HashLock? = nil
        ) -> Conditions {
        return Conditions(
            timeLock: timeLock ?? self.timeLock,
            hashLock: hashLock ?? self.hashLock
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - HashLock
class HashLock: Codable {
    let preimageHash: [PreimageHash]
    let preimageSize: Int

    init(preimageHash: [PreimageHash], preimageSize: Int) {
        self.preimageHash = preimageHash
        self.preimageSize = preimageSize
    }
}

// MARK: HashLock convenience initializers and mutators

extension HashLock {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(HashLock.self, from: data)
        self.init(preimageHash: me.preimageHash, preimageSize: me.preimageSize)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        preimageHash: [PreimageHash]? = nil,
        preimageSize: Int? = nil
        ) -> HashLock {
        return HashLock(
            preimageHash: preimageHash ?? self.preimageHash,
            preimageSize: preimageSize ?? self.preimageSize
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum PreimageHash: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(PreimageHash.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for PreimageHash"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - TimeLock
class TimeLock: Codable {
    let expiration: Date

    init(expiration: Date) {
        self.expiration = expiration
    }
}

// MARK: TimeLock convenience initializers and mutators

extension TimeLock {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(TimeLock.self, from: data)
        self.init(expiration: me.expiration)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        expiration: Date? = nil
        ) -> TimeLock {
        return TimeLock(
            expiration: expiration ?? self.expiration
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Transfer
class TransferObject: Codable {
    let amount: Int
    let assetId: String
    let to: String
    let from: String

    init(amount: Int, assetId: String, to: String, from: String) {
        self.amount = amount
        self.assetId = assetId
        self.to = to
        self.from = from
    }


    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        to = try container.decode(String.self, forKey: .to)
        from = try container.decode(String.self, forKey: .from)

        if let value = try? container.decode(String.self, forKey: .amount) {
            amount = Int(value) ?? 0
        } else {
            amount = try container.decode(Int.self, forKey: .amount)
        }
    }
}

// MARK: Transfer convenience initializers and mutators

extension TransferObject {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(TransferObject.self, from: data)
        self.init(amount: me.amount, assetId: me.assetId, to: me.to, from: me.from)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        amount: Int? = nil,
        assetId: String? = nil,
        to: String? = nil,
        from: String? = nil
        ) -> TransferObject {
        return TransferObject(
            amount: amount ?? self.amount,
            assetId: assetId ?? self.assetId,
            to: to ?? self.to,
            from: from ?? self.from
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
