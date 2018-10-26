//
//  Error.swift
//  cybexMobile
//
//  Created by koofrank on 2018/9/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import Localize_Swift

enum CybexError: Error {
    case networkError(code: NetworkErrorCode)
    case serviceHTTPError(desc: String)
    case serviceFriendlyError(code:Int, desc: JSON)

    var localizedDescription: String {
        switch self {
        case let .networkError(code):
            return code.desc()
        case let .serviceHTTPError(desc):
            return desc
        case let .serviceFriendlyError(_, desc):
            if let localized = desc.string {
                return localized
            } else if let dic = desc.dictionaryObject {
                if Localize.currentLanguage() == "en", let enString = dic["en"] as? String {
                    return enString
                } else if let zhString = dic["zh"] as? String {
                    return zhString
                }
            }
            return ""
        }
    }
}

extension CybexError {
    enum NetworkErrorCode: Int {
        case demo

        func desc() -> String {
            switch self {

            default:
                return ""
            }
        }

    }
}

extension CybexError: Equatable {
    static func == (lhs: CybexError, rhs: CybexError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(let lhsCode), .networkError(let rhsCode)):
            return lhsCode.rawValue == rhsCode.rawValue
        case let (.serviceHTTPError(lhsCode), .serviceHTTPError(rhsCode)):
            return lhsCode == rhsCode
        case let (.serviceFriendlyError(lhsCode, lhsMsg), .serviceFriendlyError(rhsCode, rhsMsg)):
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        default:
            return false
        }
    }

}
