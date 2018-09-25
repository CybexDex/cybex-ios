//
//  Utils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import SwiftTheme
import SwiftyJSON
import SwiftyUserDefaults

func getChainId(callback:@escaping(String)->()){
    if AppConfiguration.shared.chainID.isEmpty {
        let requeset = GetChainIDRequest { (id) in
            if let id = id as? String{
                callback(id)
            }else{
                callback("")
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }
    else {
        callback(AppConfiguration.shared.chainID)
    }
}

typealias BlockChainParamsType = (chain_id:String, block_id:String, block_num:Int32)
func blockchainParams(callback: @escaping(BlockChainParamsType)->()) {
    getChainId { (chainID) in
        let requeset = GetObjectsRequest(ids: [objectID.dynamic_global_property_object.rawValue]) { (infos) in
            if let infos = infos as? (block_id:String,block_num:String) {
                callback((chain_id: chainID, block_id: infos.block_id, block_num: Int32(infos.block_num)!))
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }
}

func calculateFee(_ operation:String, focus_asset_id:String, operationID:ChainTypesOperations = .limit_order_create, filterRepeat:Bool = true,completion:@escaping (_ success:Bool, _ amount:Decimal, _ assetID:String)->()) {
    let request = GetRequiredFees(response: { (data) in
        if let fees = data as? [Fee], let cyb_amount = fees.first?.amount.toDouble() {
            
            let cyb = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
                return balance.asset_type == AssetConfiguration.CYB
            }).first?.balance.toDouble() ?? 0
            
            if cyb >= cyb_amount {
                let amount = getRealAmount(AssetConfiguration.CYB, amount: cyb_amount.string)
                
                completion(true, amount, AssetConfiguration.CYB)
            }
            else {
                let request = GetRequiredFees(response: { (data) in
                    if let fees = data as? [Fee], let base_amount = fees.first?.amount.toDouble() {
                        if let base = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
                            return balance.asset_type == focus_asset_id
                        }).first {
                            if base.balance.toDouble()! >= base_amount {
                                let amount = getRealAmount(focus_asset_id, amount: base_amount.string)
                                
                                completion(true, amount, focus_asset_id)
                            }
                            else {//余额不足
                                completion(false, getRealAmount(AssetConfiguration.CYB, amount: cyb_amount.string), AssetConfiguration.CYB)
                                
                            }
                        }
                        else {
                            completion(false, getRealAmount(AssetConfiguration.CYB, amount: cyb_amount.string), AssetConfiguration.CYB)
                        }
                    }
                    else {
                        completion(false, getRealAmount(AssetConfiguration.CYB, amount: cyb_amount.string), AssetConfiguration.CYB)
                    }
                }, operationStr: operation, assetID: focus_asset_id, operationID: operationID)
                
                CybexWebSocketService.shared.send(request: request)
            }
            
            
        }
        else {
            completion(false, 0, "")
        }
    }, operationStr: operation, assetID: AssetConfiguration.CYB, operationID: operationID)
    
    CybexWebSocketService.shared.send(request: request)
}

func calculateAssetRelation(assetID_A_name:String, assetID_B_name:String) -> (base:String, quote:String) {
    let relation:[String] = AssetConfiguration.order_name
    
    
    var indexA = -1
    var indexB = -1
    
    if let index = relation.index(of: assetID_A_name) {
        indexA = index
    }
    
    if let index = relation.index(of: assetID_B_name) {
        indexB = index
    }
    
    
    if indexA > -1 && indexB > -1 {
        if indexA < indexB {
            return (assetID_A_name, assetID_B_name)
        }
        else {
            return (assetID_B_name, assetID_A_name)
        }
    }
    else if indexA < indexB {
        return (assetID_B_name, assetID_A_name)
    }
    else if indexA > indexB {
        return (assetID_A_name, assetID_B_name)
    }
    else {
        if assetID_A_name < assetID_B_name {
            return (assetID_A_name, assetID_B_name)
        }
        else {
            return (assetID_B_name, assetID_A_name)
        }
    }
    
}



//********************深度优化************************
// MARK : 传入quote 导出多少个ETH。多少个CYB
/**
 规则:
 1 如果返回的都非0/都为0，则直接返回
 2 先判断CYB/ETH 或者ETH/CYB 是否有值，如果其中一个有值就转换，反之没有数据的币对返回0
 **/
func changeToETHAndCYB(_ sender : String) -> (eth:String,cyb:String){
    let eth_base = AssetConfiguration.ETH
    let cyb_base = AssetConfiguration.CYB
    let eth_cyb  = changeCYB_ETH()
    if sender == eth_base {
        return ("1",eth_cyb)
    }else if (sender == cyb_base){
        if let eth_cyb_double = Double(eth_cyb), eth_cyb_double != 0 {
            return (String(1.0/Double(eth_cyb)!),"1")
        }
    }
    
    
    var result = (eth:"0",cyb:"0")
    let homeBuckets : [HomeBucket] = app_data.data.value
    for homeBuck : HomeBucket in homeBuckets {
        let bucket = getCachedBucket(homeBuck)
        
        if homeBuck.base == eth_base && homeBuck.quote == sender {
            if bucket.price == ""{
                continue
            }
            result.eth = bucket.price.replacingOccurrences(of: ",", with: "")
        }else if homeBuck.base == cyb_base && homeBuck.quote == sender {
            if bucket.price == ""{
                continue
            }
            result.cyb = bucket.price.replacingOccurrences(of: ",", with: "")
        }
    }
    
    if (result.eth == "0" && result.cyb == "0") {
        var sender_rmb_price = "0"
        var eth_rmb_price = "0"
        var cyb_rmb_price = "0"
        for price in app_data.rmb_prices{
            if app_data.assetInfo[sender]?.symbol.filterJade == price.name{
                sender_rmb_price = price.rmb_price
            }else if "CYB" == price.name{
                cyb_rmb_price = price.rmb_price
            }else if "ETH" == price.name{
                eth_rmb_price = price.rmb_price
            }
        }
        if sender_rmb_price == "0"{
            return result
        }
        if eth_rmb_price != "0" {
            result.eth = String(sender_rmb_price.toDouble()! / eth_rmb_price.toDouble()!)
            result.cyb = String (eth_cyb.toDouble()! * result.eth.toDouble()!)
        }else if cyb_rmb_price != "0"{
            result.cyb = String(sender_rmb_price.toDouble()! / cyb_rmb_price.toDouble()!)
            result.eth = String (eth_cyb.toDouble()! * 1 / result.cyb.toDouble()!)
        }
        return result
        
    }else if (result.eth != "0" && result.cyb != "0"){
        return result
    }else {
        if eth_cyb != "0" {
            if(result.eth == "0"){
                result.eth = String(Double(result.cyb)! * Double(1 / Double(eth_cyb)!))
            }else if(result.cyb == "0"){
                result.cyb = String(Double(result.eth)! * Double(changeCYB_ETH())!)
            }
            return result
        }
        return result
    }
}



// 获取CYB和ETH的转换关系
/**
 如果CYB作为base  ETH作为quote。没有值，则ETH作为quote  CYB作为base，如果都没有值返回0
 **/
// CYB:base  ETH:quote
func changeCYB_ETH() -> String{
    //  return "0"
    let cyb_base   = AssetConfiguration.CYB
    let eth_quote  = AssetConfiguration.ETH
    var result     = getRelationWithIds(base: cyb_base, quote: eth_quote)
    if result != "0"{
        return result
    }
    let homeBuckets : [HomeBucket] = app_data.data.value
    for homeBuck : HomeBucket in homeBuckets {
        if homeBuck.base == cyb_base && homeBuck.quote == eth_quote {
            
            let bucket = getCachedBucket(homeBuck)
            result = bucket.price.replacingOccurrences(of: ",", with: "")
            break
        }
    }
    if result == "0"{
        for homeBuck : HomeBucket in homeBuckets {
            if homeBuck.base == eth_quote && homeBuck.quote == cyb_base {
                let bucket = getCachedBucket(homeBuck)
                result = bucket.price.replacingOccurrences(of: ",", with: "")
                break
            }
        }
        if result != "0"{
            if result == "" {
                return "0"
            }
            result = String(1 / result.toDouble()!)
        }
    }
    
    return result
}

// 根据base 和quote对比的RMB 然后转换
func getRelationWithIds(base:String,quote:String) -> String{
    let rmb_prices = AppConfiguration.shared.appCoordinator.state.property.rmb_prices
    let base_name  = app_data.assetInfo[base]?.symbol.filterJade ?? "--"
    let quote_name = app_data.assetInfo[quote]?.symbol.filterJade ?? "--"
    var base_rmb = "0"
    var quote_rmb = "0"
    for price in rmb_prices {
        if price.name == base_name{
            base_rmb = price.rmb_price
        }else if price.name == quote_name{
            quote_rmb = price.rmb_price
        }
    }
    
    if base_rmb != "0" && quote_rmb != "0" {
        return String(quote_rmb.toDouble()! / base_rmb.toDouble()!)
    }
    return "0"
}





func getCachedBucket(_ homebucket:HomeBucket) -> BucketMatrix {
    var result:BucketMatrix?
    var matrixs = app_state.property.matrixs.value
    
    if let bucket = matrixs[Pair(base:homebucket.base, quote:homebucket.quote)] {
        result = bucket
    }
    
    return result ?? BucketMatrix(homebucket)
    
}


func getRealAmount(_ id : String ,amount : String) -> Decimal {
    guard let asset = app_data.assetInfo[id] else {
        return 0
    }
    
    let precisionNumber = pow(10, asset.precision)
    
    if let amountDecimal = amount.toDecimal() {
        return amountDecimal / precisionNumber
    }
    
    return 0
}

func getRealAmountDouble(_ id : String ,amount : String) -> Double {
    guard let asset = app_data.assetInfo[id] else {
        return 0
    }
    
    if let d = Double(amount) {
        return d / pow(10, asset.precision.double)
    }
    
    return 0
}

func saveImageToPhotos(){
    guard let window = UIApplication.shared.keyWindow else { return }
    
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
    
    window.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
}


// 得到一个ID获取最后一个数据
func getUserId(_ userId:String)->Int{
    if userId.contains("."){
        return Int(String.init(userId.split(separator: ".").last!))!
    }
    return 0
}


func getWithdrawDetailInfo(addressInfo:String,amountInfo:String,withdrawFeeInfo:String,gatewayFeeInfo:String,receiveAmountInfo:String,isEOS:Bool,memoInfo:String) -> [NSAttributedString]{
    let address :String = R.string.localizable.utils_address.key.localized()
    let amount : String = R.string.localizable.utils_amount.key.localized()
    let gatewayFee : String = R.string.localizable.utils_withdrawfee.key.localized()
    let withdrawFee : String = R.string.localizable.utils_gatewayfee.key.localized()
    let receiveAmount : String = R.string.localizable.utils_receiveamount.key.localized()
    let memo : String = R.string.localizable.withdraw_memo.key.localized()
    
    let content = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    
    return (isEOS && memoInfo.count > 0) ?
        (["<name>\(String(describing: address)):</name><\(content)>\n\(String(describing: addressInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: memo)):</name><\(content)>  \(String(describing: memoInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: amount)):</name><\(content)>  \(String(describing: amountInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: withdrawFee)):</name><\(content)>  \(String(describing: withdrawFeeInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: gatewayFee)):</name><\(content)>  \(String(describing: gatewayFeeInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: receiveAmount)):</name><\(content)>  \(String(describing: receiveAmountInfo))</\(content)>".set(style: "alertContent")] as? [NSAttributedString])! :
        (["<name>\(String(describing: address)):</name><\(content)>\n\(String(describing: addressInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: amount)):</name><\(content)>  \(String(describing: amountInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: withdrawFee)):</name><\(content)>  \(String(describing: withdrawFeeInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: gatewayFee)):</name><\(content)>  \(String(describing: gatewayFeeInfo))</\(content)>".set(style: "alertContent"),
          "<name>\(String(describing: receiveAmount)):</name><\(content)>  \(String(describing: receiveAmountInfo))</\(content)>".set(style: "alertContent")] as? [NSAttributedString])!
}

func getOpenedOrderInfo(price:String,amount:String,total:String,fee:String,isBuy:Bool) ->[NSAttributedString]{
    let priceTitle = R.string.localizable.opened_order_value.key.localized()
    let amountTitle = R.string.localizable.withdraw_amount.key.localized()
    let totalTitle = R.string.localizable.trade_history_total.key.localized()
    let feeTitle = R.string.localizable.openedorder_fee_title.key.localized()
    
    let priceContentStyle = isBuy ? "content_buy" : "content_sell"
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    
    let result = fee.count == 0 ? (["<name>\(priceTitle): </name><\(priceContentStyle)>\(price)</\(priceContentStyle)>".set(style: "alertContent"),
                                    "<name>\(amountTitle): </name><\(contentStyle)>\(amount)</\(contentStyle)>".set(style: "alertContent"),
                                    "<name>\(totalTitle): </name><\(contentStyle)>\(total)</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])! :
        (["<name>\(priceTitle): </name><\(priceContentStyle)>\(price)</\(priceContentStyle)>".set(style: "alertContent"),
          "<name>\(amountTitle): </name><\(contentStyle)>\(amount)</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(totalTitle): </name><\(contentStyle)>\(total)</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(feeTitle): </name><\(contentStyle)>\(fee)</\(contentStyle)>".set(style: "alertContent"),] as? [NSAttributedString])!
    
    return  result
}

func getTransferInfo(_ account: String, quanitity: String, fee: String, memo: String) -> [NSAttributedString] {
    let accountTitle = R.string.localizable.transfer_account_title.key.localized()
    let quantityTitle = R.string.localizable.transfer_quantity.key.localized()
    let feeTitle = R.string.localizable.transfer_fee.key.localized()
    let memoTitle = R.string.localizable.transfer_memo.key.localized()
    
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    
    return memo.trimmed.count != 0 ? (["<name>\(String(describing: accountTitle)):</name>  <\(contentStyle)>\(String(describing: account))</\(contentStyle)>".set(style: "alertContent"),
                                       "<name>\(String(describing: quantityTitle)):</name><\(contentStyle)>  \(String(describing: quanitity))</\(contentStyle)>".set(style: "alertContent"),
                                       "<name>\(String(describing: feeTitle)):</name><\(contentStyle)>  \(String(describing: fee))</\(contentStyle)>".set(style: "alertContent"),
                                       "<name>\(String(describing: memoTitle)):</name><\(contentStyle)>  \(String(describing: memo))</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])! :
        (["<name>\(String(describing: accountTitle)):</name>  <\(contentStyle)>\(String(describing: account))</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(String(describing: quantityTitle)):</name><\(contentStyle)>  \(String(describing: quanitity))</\(contentStyle)>".set(style: "alertContent"),
          "<name>\(String(describing: feeTitle)):</name><\(contentStyle)>  \(String(describing: fee))</\(contentStyle)>".set(style: "alertContent")] as? [NSAttributedString])!
}

func confirmDeleteWithDrawAddress(_ info:WithdrawAddress) -> [NSAttributedString] {
    
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    
    let isEOS = info.currency == AssetConfiguration.EOS
    let existMemo = info.memo != nil && !info.memo!.isEmpty
    
    var result:[NSAttributedString] = []
    
    let title = "<\(contentStyle)>" + (isEOS ? R.string.localizable.delete_confirm_account.key.localized() : R.string.localizable.delete_confirm_address.key.localized()) + "</\(contentStyle)>"
    result.append(title.set(style: StyleNames.alertContent.rawValue)!)
    
    let note = "<name>" + R.string.localizable.address_mark.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.name)" + "</\(contentStyle)>"
    result.append(note.set(style: StyleNames.alertContent.rawValue)!)
    
    let address = "<name>" + (isEOS ? R.string.localizable.accountTitle.key.localized() : R.string.localizable.address.key.localized()) + "：</name>" + "<\(contentStyle)>" + "\(info.address)" + "</\(contentStyle)>"
    result.append(address.set(style: StyleNames.alertContent.rawValue)!)
    
    if existMemo {
        let memo = "<name>" + R.string.localizable.withdraw_memo.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.memo!)" + "</\(contentStyle)>"
        result.append(memo.set(style: StyleNames.alertContent.rawValue)!)
    }
    
    return result
}

func confirmDeleteTransferAddress(_ info:TransferAddress) -> [NSAttributedString] {
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    
    var result:[NSAttributedString] = []
    
    let title = "<\(contentStyle)>" + R.string.localizable.delete_confirm_account.key.localized() + "</\(contentStyle)>"
    result.append(title.set(style: StyleNames.alertContent.rawValue)!)
    
    let note = "<name>" + R.string.localizable.address_mark.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.name)" + "</\(contentStyle)>"
    result.append(note.set(style: StyleNames.alertContent.rawValue)!)
    
    let address = "<name>" + R.string.localizable.accountTitle.key.localized() + "：</name>" + "<\(contentStyle)>" + "\(info.address)" + "</\(contentStyle)>"
    result.append(address.set(style: StyleNames.alertContent.rawValue)!)
    
    
    return result
}

func confirmSubmitCrowd(_ name:String, amount:String, fee:String) -> [NSAttributedString] {
    let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "content_dark" : "content_light"
    
    var result:[NSAttributedString] = []
    
    let title = R.string.localizable.eto_submit_title.key.localizedFormat(name).tagText(contentStyle)
    result.append(title.set(style: StyleNames.alertContent.rawValue)!)
    
    let note = (R.string.localizable.transfer_quantity.key.localized() + ": ").tagText("name") + amount.tagText(contentStyle)
    
    result.append(note.set(style: StyleNames.alertContent.rawValue)!)
    
    let address = (R.string.localizable.transfer_fee.key.localized() + ": " ).tagText("name") + fee.tagText(contentStyle)
    result.append(address.set(style: StyleNames.alertContent.rawValue)!)
    
    return result
}


func checkMaxLength(_ sender:String,maxLength:Int) ->String{
    if sender.contains("."){
        let stringArray = sender.components(separatedBy: ".")
        if let last = stringArray.last,last.count > maxLength,let first = stringArray.first,let maxLast = last.substring(from: 0, length: maxLength){
            return first + "." + maxLast
        }
    }
    return sender
}

func addressOf(_ o: UnsafeRawPointer) -> Int {
    return Int(bitPattern: o)
}

func addressOf<T: AnyObject>(_ o: T) -> Int {
    return unsafeBitCast(o, to: Int.self)
}

func getBalanceWithAssetId(_ asset:String) -> Balance? {
    if let balances = UserManager.shared.balances.value {
        for balance in balances {
            if balance.asset_type == asset{
                return balance
            }
        }
        return nil
    }
    return nil
}

func getTimeZone() -> TimeInterval {
    let timeZone = TimeZone.current
    return TimeInterval(timeZone.secondsFromGMT(for: Date()))
}

enum fundType : String {
    case WITHDRAW
    case DEPOSIT
    case ALL
}

func getWithdrawAndDepositRecords(_ accountName : String, asset : String, fundType : fundType, size : Int, offset : Int, expiration : Int ,callback:@escaping (TradeRecord?)->()) {
    
    var paragram = ["op":["accountName": accountName, "asset":asset, "fundType": fundType.rawValue, "size": Int32(size), "offset": Int32(offset),"expiration":expiration],"signer":"" ] as [String : Any]
    
    let operation = BitShareCoordinator.getRecodeLoginOperation(accountName, asset: asset, fundType: fundType.rawValue, size: Int32(size), offset: Int32(offset), expiration: Int32(expiration))
    if let operation = operation {
        let json = JSON(parseJSON: operation)
        let signer = json["signer"].stringValue
        paragram["signer"] = signer
        SimpleHTTPService.recordLogin(paragram).done { (result) in
            if let result = result {
                let url = AppConfiguration.RECODE_RECODES + "/" + accountName + "/?asset=" + asset + "&fundType=" + fundType.rawValue + "&size=" + "\(Int32(size))&offset=\(Int32(offset))"
                SimpleHTTPService.fetchRecords(url, signer: result).done({ (data) in
                    callback(data)
                }).catch({ (error) in
                    callback(nil)
                })
            }
            else {
                callback(nil)
            }
            }.catch { (error) in
                callback(nil)
        }
    }
}

func sortNameBasedonAddress(_ names: [AddressName]) -> [String] {
    let collation = UILocalizedIndexedCollation.current()
    var newSectionsArray: [[AddressName]] = []
    
    for _ in 0 ..< collation.sectionTitles.count {
        let array = [AddressName]()
        newSectionsArray.append(array)
    }
    
    for name in names {
        let sectionNumber = collation.section(for: name, collationStringSelector: #selector(getter: AddressName.name))
        var sectionBeans = newSectionsArray[sectionNumber]
        
        sectionBeans.append(name)
        
        newSectionsArray[sectionNumber] = sectionBeans
    }
    
    for i in 0 ..< collation.sectionTitles.count {
        let beansArrayForSection = newSectionsArray[i]
        
        let sortedBeansArrayForSection = collation.sortedArray(from: beansArrayForSection, collationStringSelector:  #selector(getter: AddressName.name))
        newSectionsArray[i] = sortedBeansArrayForSection as! [AddressName]
    }
    
    let sortedNames = newSectionsArray.flatMap({ $0 }).map({ $0.name })
    
    return sortedNames
}

struct WeakObject<T: AnyObject>: Equatable, Hashable {
    static func == (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
        return lhs.object === rhs.object
    }
    
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
    
    var hashValue: Int {
        if let object = self.object { return ObjectIdentifier(object).hashValue }
        else { return 0 }
    }
}

func labelBaselineOffset(_ lineHeight:CGFloat, fontHeight:CGFloat) -> Float {
    return ((lineHeight - lineHeight) / 4.0).float
}


func changeEnvironmentAction() {
    if Defaults.hasKey(.environment) && Defaults[.environment] == "test" {
        AppConfiguration.SERVER_BASE_URLString = AppConfiguration.SERVER_TEST_BASE_URLString
        AppConfiguration.SERVER_REGISTER_BASE_URLString = AppConfiguration.SERVER_REGISTER_BASE_TEST_URLString
        AppConfiguration.GATEWAY_URLString = AppConfiguration.SERVER_TEST_BASE_URLString
        
        AssetConfiguration.CYB = "1.3.0"
        AssetConfiguration.BTC = "1.3.25"
        AssetConfiguration.ETH = "1.3.18"
        AssetConfiguration.EOS = "1.3.967"
        AssetConfiguration.market_base_assets = [AssetConfiguration.ETH, AssetConfiguration.CYB, AssetConfiguration.BTC]
    }
    else {
        AppConfiguration.SERVER_BASE_URLString = "https://app.cybex.io/"
        AppConfiguration.SERVER_REGISTER_BASE_URLString = "https://faucet.cybex.io/"
        AppConfiguration.GATEWAY_URLString = "https://gateway.cybex.io/gateway"
        
        AssetConfiguration.CYB = "1.3.0"
        AssetConfiguration.BTC = "1.3.3"
        AssetConfiguration.ETH = "1.3.2"
        AssetConfiguration.EOS = "1.3.4"
        AssetConfiguration.market_base_assets = [AssetConfiguration.ETH,AssetConfiguration.CYB,AssetConfiguration.USDT,AssetConfiguration.BTC]
    }
}
