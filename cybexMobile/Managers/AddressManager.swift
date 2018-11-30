//
//  AddressManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

struct TransferAddress: Codable, DefaultsSerializable, Equatable {
    var id: String
    var name: String//标签
    var address: String
}

class AddressName: NSObject {
    @objc var name: String
    init(name: String) {
        self.name = name
    }
}

extension TransferAddress: DefaultsDefaultArrayValueType {
    static let defaultArrayValue: [TransferAddress] = []
}

struct WithdrawAddress: Codable, DefaultsSerializable, Equatable {
    var id: String
    var name: String//标签
    var address: String//地址或者账户
    var currency: String
    var memo: String?
}

extension WithdrawAddress: DefaultsDefaultArrayValueType {
    static let defaultArrayValue: [WithdrawAddress] = []
}

class AddressManager {
    static let shared = AddressManager()

    private init() {

    }

    func getUUID() -> String {
        return NSUUID().uuidString
    }

    func getWithDrawAddressListWith(_ currency: String) -> [WithdrawAddress] {
        let list = Defaults[.withdrawAddressList]

        return list.filter({$0.currency == currency })
    }

    func containAddressOfWithDraw(_ address: String, currency: String) -> (Bool, [WithdrawAddress]) {
        let list = Defaults[.withdrawAddressList]

        let filterList = list.filter { (info) -> Bool in
            return info.currency == currency
            }.filter { (info) -> Bool in
                return info.address == address
        }

        if filterList.count > 0 {
            return (true, filterList)
        }

        return (false, [])
    }

    func containWithDrawAddress(_ id: String) -> (Bool, WithdrawAddress?) {
        let list = Defaults[.withdrawAddressList]

        let filterList = list.filter { (info) -> Bool in
            return info.id == id
        }

        if filterList.count > 0 {
            return (true, filterList.first!)
        }

        return (false, nil)
    }

    func addWithDrawAddress(_ info: WithdrawAddress) {
        var list = Defaults[.withdrawAddressList]

        list.append(info)
        Defaults[.withdrawAddressList] = list
    }

    @discardableResult
    func removeWithDrawAddress(_ id: String) -> Bool {
        var list = Defaults[.withdrawAddressList]

        let result = containWithDrawAddress(id)

        if result.0 {
            list.removeAll(result.1!)
            Defaults[.withdrawAddressList] = list

            return true
        }

        return false
    }

    // MARK: - - Transfer

    func getTransferAddressList() -> [TransferAddress] {
        let list = Defaults[.transferAddressList]

        return list
    }

    func containAddressOfTransfer(_ address: String) -> (Bool, [TransferAddress]) {
        let list = Defaults[.transferAddressList]

        let filterList = list.filter { (info) -> Bool in
            return info.address == address
        }

        if filterList.count > 0 {
            return (true, filterList)
        }

        return (false, [])
    }

    func containTransferAddress(_ id: String) -> (Bool, TransferAddress?) {
        let list = Defaults[.transferAddressList]

        let filterList = list.filter { (info) -> Bool in
            return info.id == id
        }

        if filterList.count > 0 {
            return (true, filterList.first!)
        }

        return (false, nil)
    }

    func addTransferAddress(_ info: TransferAddress) {
        var list = Defaults[.transferAddressList]

        list.append(info)
        Defaults[.transferAddressList] = list
    }

    @discardableResult
    func removeTransferAddress(_ id: String) -> Bool {
        var list = Defaults[.transferAddressList]

        let result = containTransferAddress(id)

        if result.0 {
            list.removeAll(result.1!)
            Defaults[.transferAddressList] = list

            return true
        }

        return false
    }
}
