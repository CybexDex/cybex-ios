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

/**
 apollo-codegen generate *.graphql --schema schema.json --output GraphQLAPI.swift
 
 apollo-codegen print-schema schema.json
 **/
class GraphQLManager {
  let apollo = ApolloClient(url: URL(string: "https://gateway.cybex.io/gateway")!)

  static let shared = GraphQLManager()
  
  private init() {

  }
  
  func verifyAddress(assetName:String, address:String) -> PromiseKit.Promise<WithdrawAddressInfo?> {
    let (promise, seal) = PromiseKit.Promise<WithdrawAddressInfo?>.pending()

    let _ = apollo.watch(query: VerifyAddressQuery(asset: assetName, address:address), cachePolicy:.fetchIgnoringCacheData, queue: Await.Queue.await) { (result, error) in
      if let _ = error {
        seal.fulfill(nil)
        return
      }

     seal.fulfill(result?.data?.verifyAddress.fragments.withdrawAddressInfo)
    }
    
    return promise
  }
  
  func getWithdrawInfo(assetName:String) -> PromiseKit.Promise<WithdrawinfoObject?> {
    let (promise, seal) = PromiseKit.Promise<WithdrawinfoObject?>.pending()

    let _ = apollo.watch(query: GetWithdrawInfoQuery(type: assetName), cachePolicy:.fetchIgnoringCacheData, queue: Await.Queue.await) { (result, error) in
      if let _ = error {
        seal.fulfill(nil)
        return
      }
      
      seal.fulfill(result?.data?.withdrawInfo.fragments.withdrawinfoObject)
    }
    
    return promise
  }
  
  func getDepositAddress(accountName:String) -> PromiseKit.Promise<AccountAddressRecord?> {
    let (promise, seal) = PromiseKit.Promise<AccountAddressRecord?>.pending()

    let _ = apollo.watch(query: GetDepositAddressQuery(accountName: accountName)) { (result, error) in
      if let _ = error {
        seal.fulfill(nil)
        return
      }
      seal.fulfill(result?.data?.getDepositAddress?.fragments.accountAddressRecord)
    }
    
    return promise
  }
  
  func updateDepositAddress(accountName:String, assetName:String) -> PromiseKit.Promise<AccountAddressRecord?> {
    let (promise, seal) = PromiseKit.Promise<AccountAddressRecord?>.pending()
    
    let _ = apollo.perform(mutation: NewDepositAddressMutation(accountName: accountName, asset: assetName)) { (result, error) in
      if let _ = error {
        seal.fulfill(nil)
        return
      }
      seal.fulfill(result?.data?.newDepositAddress.fragments.accountAddressRecord)
    }
   
    return promise
  }

}
