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

func gChatReducer(action: Action, state: ChatState?) -> ChatState {
    let state = state ?? ChatState()

    switch action {
    case let action as ChatFetchedAction :
        state.messages.accept(changeModelToViewModel(action.data))
    default:
        break
    }

    return state
}


func nameAttributeString(_ sender: String) -> NSAttributedString {
    var attributeKeys = [NSAttributedString.Key: Any]()
    attributeKeys[NSAttributedString.Key.foregroundColor] = UIColor.steel
    if let name = UserManager.shared.name.value {
        if sender == name + ":" {
            attributeKeys[NSAttributedString.Key.foregroundColor] = UIColor.pastelOrange
        }
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
        if message.signed {
            name = message.userName + ":"
        }
        else {
            name = R.string.localizable.chat_message_guest.key.localized() + ":"
        }
        
        let nameAttribute = nameAttributeString(name)
        let messageAttribute = messageAttributeString("  " + message.message)
        
        let attributedText = NSMutableAttributedString(attributedString: nameAttribute)
        attributedText.append(messageAttribute)
        
        return ChatCommonMessage(attributedText: attributedText, sender: Sender(id: "101010", displayName: message.userName), messageId: "\(message.msgID)", date: Date())
    })
}

