//
//  Record.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct Record : HandyJSON {
  var accountName : String = ""
  var address : String = ""
  var amount : Int = 0
  var asset : String = ""
  var coinType : String = ""
  var fundType : String = ""
  var state : String = ""
  var updateAt : Date!
  
  mutating func mapping(mapper: HelpingMapper) {
    mapper <<<
      updateAt <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss")
  }
  init() {}
}

open class GemmaDateFormatTransform: DateFormatterTransform {
  
  public init(formatString: String) {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = formatString
    
    super.init(dateFormatter: formatter)
  }
}


struct TradeRecord : HandyJSON {
  var total : Int = 0
  var size : Int = 0
  var offset : Int = 0
  var records : [Record]!
  
  
  init() {}
}

