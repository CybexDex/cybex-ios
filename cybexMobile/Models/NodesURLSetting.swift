//
//  NodesURLSetting.swift
//  cybexMobile
//
//  Created by koofrank on 2019/6/17.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct NodesURLSettingModel: HandyJSON {
    var mdp: String = ""
    var nodes: [String] = []
    var limitOrder: String = ""
    var eto: String = ""
    var gateway1: String = ""
    var gateway1Query: String = ""
    var gateway2: String = ""


    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< limitOrder                   <-- "limit_order"
        mapper <<< gateway1Query           <-- "gateway1_query"
    }

}
