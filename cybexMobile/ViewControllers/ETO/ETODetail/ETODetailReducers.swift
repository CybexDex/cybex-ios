//
//  ETODetailReducers.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ETODetailReducer(action:Action, state:ETODetailState?) -> ETODetailState {
    let state = state ?? ETODetailState()
    
    switch action {
    case let action as SetProjectDetailAction:
        state.data.accept(transferProjectModel(action.data))
    case let action as FetchUserStateAction:
        state.userState.accept(action.data)
    default:
        break
    }
    return state
}

func transferProjectModel(_ sender: ETOProjectModel) -> ETOProjectViewModel{
    
    return ETOProjectViewModel(sender)
}




