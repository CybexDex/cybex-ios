//
//  EvaProject.swift
//  cybexMobile
//
//  Created by dzm on 2018/12/27.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class EvaProject: HandyJSON {
    
    var id : String = "" //主键ID
    var logo : String = "" //项目名称
    var name : String = "" //token
    var tokenName : String = ""
    var premium : String = ""  //一句话描述
    var industry : String = "" //行业
    var score : String = "" //项目评分
    var hypeScore : String = "" //热度评级
    var investmentRating : String = "" //投资评级
    var riskScore : String = "" //风险评级
    var tokenPriceInUsd : String = "" //token price in usd
    var platform : String = "" //platform
    var country : String = "" //country
    var icoTokenSupply : String = "" //ico token supply
    var description : String = "" //描述
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< tokenName <-- "token_name"
        mapper <<< hypeScore <-- "hype_score"
        mapper <<< investmentRating <-- "investment_rating"
        mapper <<< riskScore <-- "risk_score"
        mapper <<< tokenPriceInUsd <-- "token_price_in_usd"
        mapper <<< icoTokenSupply <-- "ico_token_supply"
    }
}
