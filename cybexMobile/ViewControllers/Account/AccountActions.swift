//
//  AccountActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya
import RxSwift
import RxCocoa

// MARK: - State
struct AccountState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: AccountPropertyState
}

struct AccountPropertyState {

}

struct AccountViewModel {
  var leftImage: UIImage?
  var name: String = ""
}

