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
        state.refreshData.accept(refreshProjectModel(action.data, viewModel: state.data.value))
    default:
        break
    }
    return state
}

func transferProjectModel(_ sender: ETOProjectModel) -> ETOProjectViewModel{
    return ETOProjectViewModel(sender)
}

func refreshProjectModel(_ sender: ETOShortProjectStatusModel,viewModel: ETOProjectViewModel?) -> ETOProjectViewModel? {
    guard let model = viewModel, var projectModel = model.projectModel else { return nil }
    projectModel.current_percent = sender.current_percent
    projectModel.status = sender.status
    projectModel.finish_at = sender.finish_at
    
    
    return ETOProjectViewModel(projectModel)
}




