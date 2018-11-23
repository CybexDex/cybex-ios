//
//  ChatDirectionIconViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

extension ChatDirectionIconView {
    func adapterModelToChatDirectionIconView(_ model:String) {
        self.contentLabel.text = model
    }
}
