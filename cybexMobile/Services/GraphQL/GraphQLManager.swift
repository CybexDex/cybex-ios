//
//  GraphQLManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Apollo

/**
 apollo-codegen generate *.graphql --schema schema.json --output api.swift
 
 apollo-codegen print-schema schema.json
 **/
class GraphQLManager {
  let apollo = ApolloClient(url: URL(string: "https://gateway.cybex.io/gateway")!)

  func send() {
    apollo.watch(query: VerifyAddressQuery(asset: "ETH", address:"0x6CdFeEF60636c90621348Be57C4b0F99F4859a33")) { (result, error) in
      if let error = error {
        NSLog("Error while fetching query: \(error.localizedDescription)")
        return
      }
      
    }
    
    apollo.watch(query: WithdrawInfoQuery(type: "ETH")) { (result, error) in
      if let error = error {
        NSLog("Error while fetching query: \(error.localizedDescription)")
        return
      }
      
    }
    
    apollo.watch(query: GetDepositAddressQuery(accountName: "cybex-test")) { (result, error) in
      if let error = error {
        NSLog("Error while fetching query: \(error.localizedDescription)")
        return
      }
      
    }
    
    apollo.perform(mutation: NewDepositAddressMutation(accountName: "cybex-test", asset: "ETH")) { (result, error) in
      if let error = error {
        NSLog("Error while attempting to upvote post: \(error.localizedDescription)")
      }
      
    }
  }
}
