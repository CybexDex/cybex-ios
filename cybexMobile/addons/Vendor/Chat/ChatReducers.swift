//
//  ChatReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import ChatRoom
import SwiftTheme

func gChatReducer(action: ReSwift.Action, state: ChatState?) -> ChatState {
    let state = state ?? ChatState()

    switch action {
    case let action as ChatFetchedAction:
        state.messages.accept((changeModelToViewModel(action.data),isRefresh: action.isRefresh))
    case let action as ChatUpdateMemberAction:
        state.numberOfMember.accept(action.data)
    case let action as ChatConnectStateAcion:
        state.chatState.accept(action.data)
    case let action as ChatSendStateAction:
        state.sendState.accept(action.data)
    case let action as ChatRefreshAction:
        state.refreshMessage.accept(action.data)
    case let action as ChatReloadDataAction:
        state.messages.accept((action.data, isRefresh: true))
    default:
        break
    }

    return state
}


func nameAttributeString(_ sender: String, isRealName: Bool) -> NSAttributedString {
    var attributeKeys = [NSAttributedString.Key: Any]()
    if isRealName {
        attributeKeys[NSAttributedString.Key.foregroundColor] = UIColor.primary
    }
    else {
        attributeKeys[NSAttributedString.Key.foregroundColor] = UIColor.steel
    }
    attributeKeys[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 14)
    return NSAttributedString(string: sender, attributes: attributeKeys)
}

func messageAttributeString(_ sender: String) -> NSAttributedString {
    var attributeKeys = [NSAttributedString.Key: Any]()
    attributeKeys[NSAttributedString.Key.foregroundColor] = ThemeManager.currentThemeIndex == 0 ? UIColor.white80 : UIColor.darkTwo
    attributeKeys[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 14)
    return NSAttributedString(string: sender, attributes: attributeKeys)
}


func changeModelToViewModel(_ sender: [ChatMessage]) -> [ChatCommonMessage] {
    
    return sender.map({ (message) -> ChatCommonMessage in
        var name = ""
        var isRealName = false
        if let userName = UserManager.shared.name.value {
            if message.userName == userName {
                isRealName = true
            }
        }
        if message.signed {
            if message.userName.count > 15 {
                name = message.userName.substring(from: 0, length: 15)! + "..." + ":"
            }
            else {
                name = message.userName + ":"
            }
        }
        else {
            name = R.string.localizable.chat_message_guest.key.localized() + ":"
        }
        
        let nameAttribute = nameAttributeString(name, isRealName: isRealName)
        let messageAttribute = messageAttributeString("  " + message.message)
        
        let attributedText = NSMutableAttributedString(attributedString: nameAttribute)
        attributedText.append(messageAttribute)
        
        return ChatCommonMessage(attributedText: attributedText, sender: Sender(id: "101010", displayName: message.userName), messageId: "\(message.msgID)", date: Date())
    })
}

