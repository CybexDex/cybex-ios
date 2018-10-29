//
//  ShareData.swift
//  cybexMobile
//
//  Created by peng zhu on 2018/8/29.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct ShareModes: OptionSet {
    let rawValue: Int
    
    static let wechat = ShareModes(rawValue: 1)
    
    static let timeLine = ShareModes(rawValue: 2)
    
    static let qq = ShareModes(rawValue: 4)
    
    static let sina = ShareModes(rawValue: 8)
}

enum ShareType: Int {
    case none = 0
    case web
    case image
}

class ShareData: NSObject {
    
}

class ShareImageData: ShareData {
    
}

class ShareWebData: ShareData {
    
}
