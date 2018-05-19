//
//  SimpleNetwork.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import AwaitKit
import SwiftyJSON
import PromiseKit
import Alamofire

enum SimpleHttpError: Error {
  case NotExistData
}

struct Await {
  struct Queue {
    static let await = DispatchQueue(label: "com.nbltrsut.awaitqueue", attributes: .concurrent)
    static let async = DispatchQueue(label: "com.nbltrsut.asyncqueue", attributes: .concurrent)
  }
}

@discardableResult
func await<T>(_ promise: Promise<T>) throws -> T {
  return try Await.Queue.await.ak.await(promise)
}

@discardableResult
func await<T>(_ body: @escaping () throws -> T) throws -> T {
  return try Await.Queue.await.ak.await(body)
}

func async<T>(_ body: @escaping () throws -> T) -> Promise<T> {
  return Await.Queue.async.async(.promise, execute: body)
}

func async(_ body: @escaping () throws -> Void) {
  Await.Queue.async.ak.async(body)
}

class SimpleHTTPService {
  
}

extension SimpleHTTPService {
  static func requestMarketList(base : String) -> Promise<[Pair]> {
    return Promise<[Pair]> { seal in
      var request = URLRequest(url: URL(string: AppConfiguration.SERVER_MARKETLIST_URLString + base)!)
      request.cachePolicy = .reloadIgnoringCacheData
      
      Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments, completionHandler: { (response) in
        guard let value = response.result.value else {
          seal.fulfill([])
          return
        }
        
        guard let data = JSON(value).dictionaryValue["data"] else {
          seal.fulfill([])
          return
        }
        
        let pairs = data.arrayValue.map({ Pair(base:base, quote: $0.stringValue) })
        seal.fulfill(pairs)
      })
    }
    
  }
  
  static func checkVersion() -> Promise<(update: Bool, url: String, force: Bool)> {
    var request = URLRequest(url: URL(string: AppConfiguration.SERVER_VERSION_URLString)!)
    request.cachePolicy = .reloadIgnoringCacheData
    
    let (promise, seal) = Promise<(update: Bool, url: String, force: Bool)>.pending()
    
    Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments, completionHandler: { (response) in
      guard let value = response.result.value else {
        seal.fulfill((false, "", false))
        return
      }
      
      let json = JSON(value)
      
      let lastest_version = json["version"].stringValue
      
      if let cur = Version(Bundle.main.version), let remote = Version(lastest_version) {
        if cur >= remote {
          seal.fulfill((false, "", false))
          return
        }
        
        let force_data = json["force"]
        
        seal.fulfill((true, json["url"].stringValue, force_data[Bundle.main.version].boolValue))
        return
      }
      
      seal.fulfill((false, "", false))
    })
    
    return promise
  }
  
  static func requestETHPrice() -> Promise<Double>{
    var request = URLRequest(url: URL(string: AppConfiguration.ETH_PRICE)!)
    request.cachePolicy = .reloadIgnoringCacheData
    let (promise,seal) = Promise<Double>.pending()
    Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
      guard let value = response.result.value else {
        seal.fulfill(0)
        return
      }
      let json = JSON(value)
      let prices = json["prices"].arrayValue
      for price in prices {
        if price["name"] == "ETH"{
          seal.fulfill(price["value"].doubleValue)
        }
      }
      seal.fulfill(0)
    }
    return promise
  }
  
}
