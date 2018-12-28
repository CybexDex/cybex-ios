//
//  WithdrawDetailReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift

func withdrawDetailReducer(action: Action, state: WithdrawDetailState?) -> WithdrawDetailState {
    let state = state ?? WithdrawDetailState()

    switch action {
    case let action as FetchAddressInfo:
        state.data.accept(action.data)
    case let action as FetchMsgInfo:
        state.msgInfo.accept(transferWordToRechageWordData(action.data))
    default:
        break
    }

    return state
}

func transferWordToRechageWordData(_ sender: RechargeWorldInfo) -> RechageWordVMData {
    let projectName = Localize.currentLanguage() == "en" ? sender.projectNameEn : sender.projectNameCn
    let projectAddress = Localize.currentLanguage() == "en" ? sender.projectAddressEn : sender.projectAddressCn
    let projectLink = Localize.currentLanguage() == "en" ? sender.projectLinkEn : sender.projectLinkCn
    let messageInfo = Localize.currentLanguage() == "en" ? sender.enInfo : sender.cnInfo
    
    return RechageWordVMData(projectName: projectName, projectAddress: projectAddress, projectLink: projectLink, messageInfo: messageInfo)
}
