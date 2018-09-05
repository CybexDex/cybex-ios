//
//  Error.swift
//  cybexMobile
//
//  Created by koofrank on 2018/9/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

enum CybexError: Error {
    case NetworkError(code: NetworkErrorCode)
    case ServiceHTTPError(desc: String)
    case ServiceFriendlyError(code:Int, desc: String)

    var localizedDescription: String {
        switch self {
        case let .NetworkError(code):
            return code.desc()
        case let .ServiceHTTPError(desc):
            return desc
        case let .ServiceFriendlyError(_, desc):
            return desc
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
        case (.NetworkError(let lhsCode), .NetworkError(let rhsCode)):
            return lhsCode.rawValue == rhsCode.rawValue
        case let (.ServiceHTTPError(lhsCode), .ServiceHTTPError(rhsCode)):
            return lhsCode == rhsCode
        case let (.ServiceFriendlyError(lhsCode, lhsMsg), .ServiceFriendlyError(rhsCode, rhsMsg)):
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        default:
            return false
        }
    }
    
}

