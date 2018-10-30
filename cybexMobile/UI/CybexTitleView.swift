//
//  CybexTitleView.swift
//  Demo
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import SwiftTheme

class CybexTitleView: UIView {

    enum Event: String {
        case sendBtnAction
    }

    var data: [String]? {
        didSet {
            setup()
        }
    }

    let space: CGFloat = 10.0
    var buttons: [UIButton] = []
    var lineView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 1))
        view.backgroundColor = .pastelOrange
        return view
    }()

    var selectedIndex: Int = 0 {
        didSet {
            for button in buttons {
                if selectedIndex == button.tag {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            }
            self.lineView.center = CGPoint(x: buttons[selectedIndex].center.x, y: self.height - 0.5)
        }
    }

    func setup() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        let view = UIView(frame: CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1))
        view.backgroundColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white4 : UIColor.steel11
        self.addSubview(view)
        if let data = data {
            let btnWidth: CGFloat = (self.frame.width - CGFloat(data.count - 1) * space) / CGFloat(data.count)

            for index in 0...data.count - 1 {
                let btn = UIButton(frame: CGRect(x: CGFloat(index) * (btnWidth + space), y: 0, width: btnWidth, height: self.height-1))
                btn.locali = data[index]
                btn.setTitleColor(.steel, for: .normal)
                btn.setTitleColor(.pastelOrange, for: .selected)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
                btn.addTarget(self, action: #selector(selectedBtn(_:)), for: .touchUpInside)
                btn.tag = index
                self.addSubview(btn)
                if index == 0 {
                    btn.isSelected = true
                }
                buttons.append(btn)
            }
            self.lineView.center = CGPoint(x: btnWidth * 0.5, y: self.height - 0.5)
            self.addSubview(self.lineView)
        }
    }

    @objc func selectedBtn(_ sender: UIButton) {
        for button in buttons {
            if sender == button {
                sender.isSelected = true
            } else {
                button.isSelected = false
            }
        }

        self.lineView.center = CGPoint(x: sender.center.x, y: self.height - 0.5)
        self.next?.sendEventWith(Event.sendBtnAction.rawValue, userinfo: ["selectedIndex": sender.tag])
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
