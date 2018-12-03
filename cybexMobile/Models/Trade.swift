//
//  Trade.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class Fee: HandyJSON {
    var assetId: String = ""
    var amount: String = ""
    var success: Bool = false

    required init() {

    }
    func mapping(mapper: HelpingMapper) {
        mapper <<< assetId    <-- "asset_id"
        mapper <<< amount      <-- ("amount", ToStringTransform())
        mapper <<< success     <-- "success"
    }
}

class Current: HandyJSON {
    var headBlockId: String = ""
    var lastIrreversibleBlockNum: String = ""
    required init() {

    }
    func mapping(mapper: HelpingMapper) {
        mapper <<< headBlockId               <-- "head_block_id"
        mapper <<< lastIrreversibleBlockNum <-- ("last_irreversible_block_num", ToStringTransform())
    }
}

struct Trade {
    var id: String = ""
    var enable: Bool = true
    var enMsg: String = ""
    var cnMsg: String = ""
    var enInfo: String = ""
    var cnInfo: String = ""
    var amount: String = "0"
}

struct TradeMsg {
    var enMsg: String = ""
    var cnMsg: String = ""
}

struct RechargeWorldInfo {
    var projectNameCn: String = ""
    var projectAddressCn: String = ""
    var projectLinkCn: String = ""
    var projectNameEn: String = ""
    var projectAddressEn: String = ""
    var projectLinkEn: String = ""
    var enInfo: String = ""
    var cnInfo: String = ""
}


struct RechageWordVMData {
    var projectName: String = ""
    var projectAddress: String = ""
    var projectLink: String = ""
    var messageInfo: String = ""
}
