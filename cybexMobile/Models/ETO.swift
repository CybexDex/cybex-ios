//
//  ETO.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct ETOProjectModel {
    var icon_url : String = ""
    var state : String = ""
    var name : String = ""
    var mark : String = ""
    var progress : Double = 0
    var time_progress : Double = 0
    var time : String = ""
}

struct ETOProjectInfo : HandyJSON {
    
    
}


struct ETOBannerModel {
    var index : Int = 0
    var id : String = ""
    var banner : Int = 0
    var adds_banner : String = ""
    var adds_banner_lang_en : String = ""
}
