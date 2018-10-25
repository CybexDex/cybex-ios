//
//  NoticeBoardViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class NoticeBoardViewController: BaseViewController {
    var coordinator: RegisterCoordinatorProtocol?
    var password: String?

    @IBOutlet weak var noticeView: NoticeBoardView!

    override func viewDidLoad() {
        self.noticeView.data = password
    }
}

extension NoticeBoardViewController {
  @objc func confirm(_ data: [String: Any]) {
    self.coordinator?.dismiss()
  }
}
