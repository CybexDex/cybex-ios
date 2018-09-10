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
    case let action as RefrehProjectModelAction:
        refreshProjectModel(action.data, viewModel: state.data.value)
    default:
        break
    }
    return state
}

func transferProjectModel(_ sender: ETOProjectModel) -> ETOProjectViewModel{
    return ETOProjectViewModel(sender)
}

func refreshProjectModel(_ sender: ETOShortProjectStatusModel,viewModel: ETOProjectViewModel?)  {
    guard let model = viewModel else { return }
    model.current_percent.accept((sender.current_percent * 100).string(digits:0, roundingMode: .down) + "%")
    model.progress.accept(sender.current_percent)
    model.status.accept(sender.status!.description())
    model.project_state.accept(sender.status)
}




