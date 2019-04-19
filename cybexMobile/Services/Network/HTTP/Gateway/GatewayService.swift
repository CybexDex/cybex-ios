//
//  GraphQLManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Apollo
import PromiseKit

/// 网关充值提现
///
/// - 使用 GraphQL 语法
///
/// - 指定 graphql & scheme 生成API  返回 Promise
///
/// apollo-codegen generate *.graphql --schema schema.json --output GraphQLAPI.swift
///
/// apollo-codegen print-schema schema.json
///
class GatewayService {
    enum Config: NetworkHTTPEnv {
        static let productURL = URL(string: "https://gateway.cybex.io/gateway")!
        static let devURL = URL(string: "https://gateway.cybex.io/gateway")!
        static let uatURL = URL(string: "http://47.100.98.113:5681/gateway")!

        static var gatewayID: String {
            switch AppEnv.current {
            case .product:
                return "CybexGateway"
            case .test:
                return "CybexGatewayDev"
            case .uat:
                return "CybexGateway"
            }
        }
    }

    let apollo = ApolloClient(url: Config.currentEnv)

    init() {

    }


    /// 提现Memo
    ///
    /// - Parameters:
    ///   - assetName: symbol, not contain Jade
    ///   - address: 地址
    /// - Returns: memo
    class func withDrawMemo(_ assetName: String, address: String) -> String {
        return "withdraw:\(Config.gatewayID):\(assetName):\(address)"
    }

//======================= MARK: - Requests

    /// 验证提现地址合法
    ///
    /// - Parameters:
    ///   - assetName: symbol, not contain Jade
    ///   - address: address
    /// - Returns: .valid 属性为合法与否
    func verifyAddress(assetName: String, address: String) -> PromiseKit.Promise<WithdrawAddressInfo?> {
        let (promise, seal) = PromiseKit.Promise<WithdrawAddressInfo?>.pending()

        _ = apollo.fetch(query: VerifyAddressQuery(asset: assetName,
                                                   address: address),
                         cachePolicy: .fetchIgnoringCacheData,
                         queue: DispatchQueue.global()) { (result, error) in
            if error != nil {
                seal.fulfill(nil)
                return
            }

            seal.fulfill(result?.data?.verifyAddress.fragments.withdrawAddressInfo)
        }

        return promise
    }

    /// 获取提现相关内容 - 精度 手续费...
    ///
    /// - Parameter assetName: symbol, not contain Jade
    /// - Returns:
    func getWithdrawInfo(assetName: String) -> PromiseKit.Promise<WithdrawinfoObject?> {
        let (promise, seal) = PromiseKit.Promise<WithdrawinfoObject?>.pending()

        _ = apollo.fetch(
            query: GetWithdrawInfoQuery(type: assetName),
            cachePolicy: .fetchIgnoringCacheData,
            queue: DispatchQueue.global()) { (result, error) in

                if error != nil {
                    seal.fulfill(nil)
                    return
                }

                seal.fulfill(result?.data?.withdrawInfo.fragments.withdrawinfoObject)
            }
        return promise
    }

    /// 获取充值地址
    ///
    /// - Parameters:
    ///   - accountName: 账户名
    ///   - assetName: symbol, not contain Jade
    /// - Returns:
    func getDepositAddress(accountName: String, assetName: String) -> PromiseKit.Promise<AccountAddressRecord?> {
        let (promise, seal) = PromiseKit.Promise<AccountAddressRecord?>.pending()

        _ = apollo.fetch(
            query: GetDepositAddressQuery(
                accountName: accountName,
                asset: assetName),
            cachePolicy: .fetchIgnoringCacheData,
            queue: DispatchQueue.global()) { (result, error) in
                    if error != nil {
                        seal.fulfill(nil)
                        return
                    }

                    seal.fulfill(result?.data?.getDepositAddress?.fragments.accountAddressRecord)
                }

        return promise
    }

    /// 刷新充值地址
    ///
    /// - Parameters:
    ///   - accountName: 账户名
    ///   - assetName: symbol, not contain Jade
    /// - Returns:
    func updateDepositAddress(accountName: String, assetName: String) -> PromiseKit.Promise<AccountAddressRecord?> {
        let (promise, seal) = PromiseKit.Promise<AccountAddressRecord?>.pending()

        _ = apollo.perform(
            mutation: NewDepositAddressMutation(
                accountName: accountName,
                asset: assetName)) { (result, error) in
                    if error != nil {
                        seal.fulfill(nil)
                        return
                    }

                    seal.fulfill(result?.data?.newDepositAddress.fragments.accountAddressRecord)
                }

        return promise
    }

}
