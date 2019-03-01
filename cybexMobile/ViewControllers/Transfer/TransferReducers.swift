//
//  TransferReducers.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func transferReducer(action: Action, state: TransferState?) -> TransferState {
    let state = state ?? TransferState()

    switch action {
    case let action as ValidAccountAction:
        state.accountValid.accept(action.status)
    case let action as ValidAmountAction:
        main {
            state.amountValid.accept(action.isValid)
        }
    case let action as SetBalanceAction:
        state.balance.accept(action.balance)
    case let action as SetFeeAction:
        state.fee.accept(action.fee)
    case let action as SetToAccountAction:
        state.toAccount.accept(action.account)
    case _ as ResetDataAction:
        state.accountValid.accept(.unValided)
        state.amountValid.accept(false)
        state.balance.accept(nil)
        state.fee.accept(nil)
        state.account.accept("")
        state.amount.accept("")
        state.memo.accept("")
        state.toAccount.accept(nil)
    case let action as ChooseAccountAction:
        state.account.accept(action.account.address)
        state.accountValid.accept(AccountValidStatus.validSuccessed)

    case _ as CleanToAccountAction:
        state.toAccount.accept(nil)
    default:
        break
    }

    return state
}
