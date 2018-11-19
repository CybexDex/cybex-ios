//
//  ChatReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func gChatReducer(action:Action, state:ChatState?) -> ChatState {
    let state = state ?? ChatState()
        
    switch action {
    case let action as ChatFetchedAction :
        state.messages.accept(action.data)
    default:
        break
    }
        
    return state
}


