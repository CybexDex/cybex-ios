//
//  SimpleNetwork.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit
import Alamofire
import Localize_Swift

enum SimpleHttpError: Error {
    case notExistData
}

func main(_ body: @escaping @convention(block) () -> Swift.Void) {
    DispatchQueue.main.async(execute: body)
}
