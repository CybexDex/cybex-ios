//
//  NoticeBoardViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class NoticeBoardViewController: BaseViewController {
    var password: String?
    var attrText: String?

    var titleKey: String?
    var confirmKey: String?

    @IBOutlet weak var noticeView: NoticeBoardView!
    let didConfirm = Delegate<Void, Void>()

    override func viewDidLoad() {
        if let password = password {
            self.noticeView.data = password
        }

        if let attrText = attrText {
            self.noticeView.fillContent(attrText)
        }

        if let titleKey = titleKey {
            self.noticeView.title.locali = titleKey
        }

        if let confirmKey = confirmKey {
            self.noticeView.confirm.locali = confirmKey
        }
    }
}

extension NoticeBoardViewController {
    @objc func confirm(_ data: [String: Any]) {
        self.dismiss(animated: true, completion: nil)
        didConfirm.call()
    }
}
