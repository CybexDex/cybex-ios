//
//  TradeContestViewController.swift
//  cybexMobile
//
//  Created by DKM on 2019/5/13.
//  Copyright © 2019 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme
import Localize_Swift


class TradeContestViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEvent()
    }
    
    func setupUI() {
        self.localizedText = R.string.localizable.contest_notice_title.key.localizedContainer()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: R.string.localizable.contest_notice.key.localized(), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        self.contentLabel.attributedText = attributedString
        if ThemeManager.currentThemeIndex == 0 {
            self.contentLabel.textColor = .white80
        } else {
            self.contentLabel.textColor = .darkTwo
        }
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification),
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
                                                guard let self = self else { return }
                                                
                                                if ThemeManager.currentThemeIndex == 0 {
                                                    self.contentLabel.textColor = .white80
                                                } else {
                                                    self.contentLabel.textColor = .darkTwo
                                                }
                                                
        })
    }
}
