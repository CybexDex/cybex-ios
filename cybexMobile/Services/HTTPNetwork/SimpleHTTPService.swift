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
import Localize_Swift

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
    static func requestMarketList(base: String) -> Promise<[Pair]> {
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

            let pairs = data.arrayValue.map({ Pair(base: base, quote: $0.stringValue) })
            seal.fulfill(pairs)
        })

        return promise
    }

    static func checkVersion() -> Promise<(update: Bool, url: String, force: Bool, content: String)> {
        var urlString = AppConfiguration.SERVER_VERSION_APPSTORE_URLString

        if let bundleID = Bundle.main.bundleIdentifier, bundleID.contains("fir") {
            urlString = AppConfiguration.SERVER_VERSION_URLString
        }
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringCacheData

        let (promise, seal) = Promise<(update: Bool, url: String, force: Bool, content: String)>.pending()

        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments, completionHandler: { (response) in
            guard let value = response.result.value else {
                seal.fulfill((false, "", false, ""))
                return
            }

            let json = JSON(value)

            let lastest_version = json["version"].stringValue

            if let cur = Version(Bundle.main.version), let remote = Version(lastest_version) {
                if cur >= remote {
                    seal.fulfill((false, "", false, ""))
                    return
                }

                let force_data = json["force"]

                seal.fulfill((true, json["url"].stringValue, force_data[Bundle.main.version].boolValue, Localize.currentLanguage() == "en" ?  json["enUpdateInfo"].stringValue : json["cnUpdateInfo"].stringValue))
                return
            }

            seal.fulfill((false, "", false, ""))
        })

        return promise
    }

    static func requestETHPrice() -> Promise<[RMBPrices]> {
        var request = URLRequest(url: URL(string: AppConfiguration.ETH_PRICE)!)
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = 5

        let (promise, seal) = Promise<[RMBPrices]>.pending()
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

    static func requestPinCode() -> Promise<(id: String, data: String)> {
        var request = URLRequest(url: URL(string: AppConfiguration.SERVER_REGISTER_PINCODE_URLString)!)
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = 5

        let (promise, seal) = Promise<(id: String, data: String)>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill(("", ""))
                return
            }
            let json = JSON(value)
            let id = json["id"].stringValue
            let data = json["data"].stringValue

            seal.fulfill((id, data))
        }
        return promise
    }

    static func requestRegister(_ params: [String: Any]) -> Promise<(Bool, Int)> {
        var request = try! URLRequest(url: URL(string: AppConfiguration.SERVER_REGISTER_URLString)!, method: .post, headers: ["Content-Type": "application/json"])
        request.timeoutInterval = 5
        let encodedURLRequest = try! JSONEncoding.default.encode(request, with: params)

        let (promise, seal) = Promise<(Bool, Int)>.pending()

        Alamofire.request(encodedURLRequest).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
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

    static func fetchIdsInfo() -> Promise<[String]> {
        var request = URLRequest(url: URL(string: AppConfiguration.ASSET)!)
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

    static func fetchWithdrawIdsInfo() -> Promise<[Trade]> {
        var request  = URLRequest(url: URL(string: AppConfiguration.WITHDRAW)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[Trade]>.pending()
        Alamofire.request(request).responseJSON(queue: DispatchQueue.main, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }
            //  var enMsg : String = ""
            //  var cnMsg : String = ""
            let trades = JSON(value).arrayValue.map({Trade(id: $0["id"].stringValue, enable: $0["enable"].boolValue, enMsg: $0["enMsg"].stringValue, cnMsg: $0["cnMsg"].stringValue, enInfo: $0["enInfo"].stringValue, cnInfo: $0["cnInfo"].stringValue)})
            seal.fulfill(trades)
        }
        return promise
    }

    static func fetchDesipotInfo() -> Promise<[Trade]> {
        var request  = URLRequest(url: URL(string: AppConfiguration.DEPOSIT)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[Trade]>.pending()
        Alamofire.request(request).responseJSON(queue: DispatchQueue.main, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }
            let trades = JSON(value).arrayValue.map({Trade(id: $0["id"].stringValue, enable: $0["enable"].boolValue, enMsg: $0["enMsg"].stringValue, cnMsg: $0["cnMsg"].stringValue, enInfo: $0["enInfo"].stringValue, cnInfo: $0["cnInfo"].stringValue)})
            seal.fulfill(trades)
        }
        return promise
    }

    static func fetchMarketListJson() -> Promise<[ImportantMarketPair]> {
        var request  = URLRequest(url: URL(string: AppConfiguration.MARKETLISTS)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[ImportantMarketPair]>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }
            let marketLists = JSON(value).arrayValue.map({ (item) in
                ImportantMarketPair(base: item["base"].stringValue, quotes: (item["quotes"].arrayObject as? [String])!)
            })
            seal.fulfill(marketLists)
        }
        return promise
    }

    static func recordLogin(_ sender: [String: Any]) -> Promise<String?> {
        var request = try! URLRequest(url: URL(string: AppConfiguration.RECODE_LOGIN)!, method: .post, headers: ["Content-Type": "application/json"])
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringCacheData

        let encodedURLRequest = try! JSONEncoding.default.encode(request, with: sender)
        let (promise, seal) = Promise<String?>.pending()

        Alamofire.request(encodedURLRequest).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill(nil)
                return
            }
            let data = JSON(value).dictionaryValue
            if let code = data["code"]?.int, code == 200 {
                if let result = data["data"]?.dictionaryValue {
                    seal.fulfill(result["signer"]?.string)
                } else {
                    seal.fulfill(nil)
                }
            } else {
                seal.fulfill(nil)
            }
        }
        return promise
    }

    static func fetchETOHiddenRequest() -> Promise<ETOHidden?> {
        var request  = URLRequest(url: URL(string: AppConfiguration.BASE_SETTING_JSON)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<ETOHidden?>.pending()
        Alamofire.request(request).responseJSON(queue: DispatchQueue.main, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill(nil)
                return
            }
            let model = ETOHidden.deserialize(from: JSON(value).dictionaryObject)
            seal.fulfill(model)
        }
        return promise
    }

    static func fetchRecords(_ url: String, signer: String) -> Promise<TradeRecord?> {
        let headers = ["Content-Type": "application/json", "authorization": "bearer " + signer]
        var request = try! URLRequest(url: URL(string: url)!, method: .get, headers: headers)
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringCacheData

        let (promise, seal) = Promise<TradeRecord?>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill(nil)
                return
            }
            let data = JSON(value).dictionaryValue
            if let code = data["code"]?.int, code == 200 {
                if let result = data["data"]?.dictionaryObject {
                    if let callbackData = TradeRecord.deserialize(from: result) {
                        seal.fulfill(callbackData)
                    } else {
                        seal.fulfill(nil)
                    }
                }
            } else {
                seal.fulfill(nil)
            }
        }
        return promise
    }

    static func fetchAccountAsset(_ url: String, signer: String) -> Promise<AccountAssets?> {
        let headers = ["Content-Type": "application/json", "authorization": "bearer " + signer]
        var request = try! URLRequest(url: URL(string: url)!, method: .get, headers: headers)
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringCacheData

        let (promise, seal) = Promise<AccountAssets?>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill(nil)
                return
            }
            let data = JSON(value).dictionaryValue
            if let code = data["code"]?.int, code == 200 {
                if let result = data["data"]?.dictionaryObject {
                    if let callbackData = AccountAssets.deserialize(from: result) {
                        seal.fulfill(callbackData)
                    } else {
                        seal.fulfill(nil)
                    }
                }
            } else {
                seal.fulfill(nil)
            }
        }
        return promise
    }

    static func fetchHomeHotAssetJson() -> Promise<[Pair]?> {
        var request  = URLRequest(url: URL(string: AppConfiguration.HOTASSETS_JSON)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[Pair]?>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }

            guard let data = JSON(value).dictionaryValue["data"] else {
                seal.fulfill([])
                return
            }

            let pairs = data.arrayValue.map({ Pair(base: $0.dictionaryValue["base"]?.stringValue ?? "", quote: $0.dictionaryValue["quote"]?.stringValue ?? "") })
            seal.fulfill(pairs)
        }
        return promise
    }

    static func fetchAnnounceJson(_ url: String) -> Promise<[ComprehensiveAnnounce]?> {
        var request  = URLRequest(url: URL(string: url)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[ComprehensiveAnnounce]?>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }
            guard let data = JSON(value).dictionaryValue["data"] else {
                seal.fulfill([])
                return
            }
            let announces = data.arrayValue.map({ ComprehensiveAnnounce.deserialize(from: $0.dictionaryObject)!})

            seal.fulfill(announces)
        }
        return promise
    }

    static func fetchHomeItemInfo(_ url: String) -> Promise<[ComprehensiveItem]?> {
        var request  = URLRequest(url: URL(string: url)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[ComprehensiveItem]?>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }

            guard let data = JSON(value).dictionaryValue["data"] else {
                seal.fulfill([])
                return
            }

            let items = data.arrayValue.map({ ComprehensiveItem.deserialize(from: $0.dictionaryObject)})
            seal.fulfill(items as? [ComprehensiveItem])
        }
        return promise
    }

    static func fetchHomeBannerInfos(_ url: String) -> Promise<[ComprehensiveBanner]?> {
        var request  = URLRequest(url: URL(string: url)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[ComprehensiveBanner]?>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }

            guard let data = JSON(value).dictionaryValue["data"] else {
                seal.fulfill([])
                return
            }

            let banners = data.arrayValue.map({ ComprehensiveBanner.deserialize(from: $0.dictionaryObject)})
            seal.fulfill(banners as? [ComprehensiveBanner])
        }
        return promise
    }

    static func fetchBlockexplorerJson() -> Promise<[BlockExplorer]> {
        var request  = URLRequest(url: URL(string: AppConfiguration.BLOCKEXPLORER_JSON)!)
        request.cachePolicy = .reloadIgnoringCacheData
        let (promise, seal) = Promise<[BlockExplorer]>.pending()
        Alamofire.request(request).responseJSON(queue: Await.Queue.await, options: .allowFragments) { (response) in
            guard let value = response.result.value else {
                seal.fulfill([])
                return
            }
            let explorers = JSON(value).arrayValue.map({ (item) -> BlockExplorer in
                return BlockExplorer(asset: item["asset"].stringValue, explorer: item["explorer"].stringValue)
            })
            seal.fulfill(explorers)
        }
        return promise
    }
}
