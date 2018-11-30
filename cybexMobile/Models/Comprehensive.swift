//
//  Comprehensive.swift
//  cybexMobile
//
//  Created by DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct ComprehensiveItem: HandyJSON {
    var title: String = ""
    var desc: String = ""
    var icon: String = ""
    var link: String = ""
}

struct ComprehensiveAnnounce: HandyJSON {
    var title: String = ""
    var url: String = ""
}

struct ComprehensiveBanner: HandyJSON {
    var image: String = ""
    var link: String = ""
    var score: Int = 0
}

struct BlockExplorer: HandyJSON {
    var asset: String = ""
    var explorer: String = ""
}
