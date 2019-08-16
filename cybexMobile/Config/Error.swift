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
import PromiseKit

enum CybexError: Error {
    static let domain = "cybexError"
    static let common = NSError(domain: CybexError.domain, code: 0, userInfo: nil)

    case networkError(code: NetworkErrorCode)
    case serviceHTTPError(desc: String)
    case serviceFriendlyError(code:Int, desc: JSON)
    case keychainOperation(status: OSStatus)
    case generalError(reason: GeneralErrorReason)
    case tipError(_ reason: UserTipError)

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
        case let .keychainOperation(status):
            return "\(status)"
        case .generalError(let reason):
            return reason.errorDescription
        case .tipError(let reason):
            return reason.errorDescription
        }
    }
}

extension CybexError {
    enum UserTipError {
        case userNotExist
        case unlockFail
        case registerFail(code: Int)
        case loginFail
        case assetNotExist

        case databaseApiError(json: JSON)

        var errorDescription: String {
            switch self {
            case let .registerFail(code):
                if code == 403 {
                    return R.string.localizable.registerFail403.key.localized()
                } else if code == 429 {
                    return R.string.localizable.registerFail429.key.localized()
                } else {
                    return R.string.localizable.registerFail.key.localized()
                }
            case let .databaseApiError(json: json):
                return ""
            default:
                return ""
            }
        }
    }
}

extension CybexError {
    enum GeneralErrorReason {
        /// Cannot convert `string` to valid data with `encoding`. Code 4001.
        case conversionError(string: String, encoding: String.Encoding)

        /// The method is invoked with an invalid parameter. Code 4002.
        case parameterError(parameterName: String, description: String)

        var errorDescription: String {
            switch self {
            case .conversionError(let text, let encoding):
                return "Cannot convert target \"\(text)\" to valid data under \(encoding) encoding."
            case .parameterError(let parameterName, let reason):
                return "Method invoked with an invalid parameter \"\(parameterName)\". Reason: \(reason)"
            }
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

public enum CybexErrorUserInfoKey: String {
    case underlyingError
    case statusCode
    case resultCode
    case type
    case data
    case APIError
    case raw
    case url
    case message
    case status
    case text
    case encoding
    case parameterName
    case reason
    case index
    case key
    case got
}
