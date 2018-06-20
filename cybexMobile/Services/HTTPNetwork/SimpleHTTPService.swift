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
    static let serialAsync = DispatchQueue(label: "com.nbltrsut.asyncqueue.serial")
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

func await(_ body: @escaping () throws -> Void) {
  Await.Queue.await.ak.async(body)
}

func serialAsync(_ body: @escaping () throws -> Void) {
  Await.Queue.serialAsync.ak.async(body)
}

func main(_ body: @escaping @convention(block) () -> Swift.Void) {
  DispatchQueue.main.async(execute: body)
}

class SimpleHTTPService {
  
}

extension SimpleHTTPService {
  static func requestMarketList(base : String) -> Promise<[Pair]> {
    var request = URLRequest(url: URL(string: AppConfiguration.SERVER_MARKETLIST_URLString + base)!)
    request.timeoutInterval = 5
    request.cachePolicy = .reloadIgnoringCacheData
    
    let (promise, seal) = Promise<[Pair]>.pending()
    
    Alamofire.request(request).responseJSON(queue: DispatchQueue.main, options: .allowFragments, completionHandler: { (response) in
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
  
    return promise
    
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
  
  
  static func requestETHPrice() -> Promise<[RMBPrices]>{
    var request = URLRequest(url: URL(string: AppConfiguration.ETH_PRICE)!)
    request.cachePolicy = .reloadIgnoringCacheData
    let (promise,seal) = Promise<[RMBPrices]>.pending()
    Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
      var rmb_prices = [RMBPrices]()
      guard let value = response.result.value else {
        seal.fulfill([])
        return
      }
      let json = JSON(value)
      
      let prices = json["prices"].arrayValue
      for price in prices {
        rmb_prices.append(RMBPrices(name: price["name"].stringValue, rmb_price: price["value"].stringValue == "" ? "0" : price["value"].stringValue))
      }
      seal.fulfill(rmb_prices)
    }
    return promise
  }
  
  
  
  static func requestPinCode() -> Promise<(id:String, data:String)> {
    var request = URLRequest(url: URL(string: AppConfiguration.SERVER_REGISTER_PINCODE_URLString)!)
    request.cachePolicy = .reloadIgnoringCacheData
    
    let (promise,seal) = Promise<(id:String, data:String)>.pending()
    Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
      guard let value = response.result.value else {
        seal.fulfill(("", ""))
        return
      }
      let json = JSON(value)
      let id = json["id"].stringValue
      let data = json["data"].stringValue
     
      seal.fulfill((id,data))
    }
    return promise
  }
  
  static func requestRegister(_ params: [String:Any]) -> Promise<(Bool, Int)> {
    let (promise,seal) = Promise<(Bool, Int)>.pending()
    
    Alamofire.request(URL(string: AppConfiguration.SERVER_REGISTER_URLString)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
      guard let value = response.result.value else {
        seal.fulfill((false, 0))
        return
      }
      
      let json = JSON(value)
      if let code = json["code"].int {
        seal.fulfill((false, code))
        return
      }
      
      seal.fulfill((true, 0))
    }
    return promise
  }
  
  static func fetchIdsInfo(_ url:String) -> Promise<[String]>{
    var request = URLRequest(url: URL(string: url)!)
    request.cachePolicy = .reloadIgnoringCacheData
    
    let (promise, seal) = Promise<[String]>.pending()
    
    Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments, completionHandler: { (response) in
      guard let value = response.result.value else {
        seal.fulfill([])
        return
      }
      let ids = JSON(value).arrayValue.map({String(describing: $0.stringValue)})
      seal.fulfill(ids)
    })
    return promise
  }
}
