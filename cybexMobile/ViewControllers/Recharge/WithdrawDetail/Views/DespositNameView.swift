//
//  DespositNameView.swift
//  cybexMobile
//
//  Created DKM on 2018/10/17.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable
class DespositNameView: CybexBaseView {

    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var protocolAddressLabel: UILabel!

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var addressView: UIView!

    var projectName: String? {
        didSet {
            guard let projectName = projectName else {
                self.nameView.isHidden = true
                self.updateHeight()
                return                
            }
            self.nameView.isHidden = false
            self.projectNameLabel.text = projectName
            self.updateHeight()
        }
    }

    var url: String? {
        didSet {
            guard let address = url else {
                self.addressView.isHidden = true
                self.updateHeight()
                return
            }
            self.addressView.isHidden = false
            let color = UIColor.steel
            let underlineAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                      NSAttributedString.Key.foregroundColor: color] as [NSAttributedString.Key: Any]
            let underlineAttributedString = NSAttributedString(string: address, attributes: underlineAttribute)
            self.protocolAddressLabel.attributedText = underlineAttributedString
            self.updateHeight()
        }
    }

    var addressURL: String? {
        didSet {

        }
    }

    enum Event: String {
        case despositNameViewDidClicked
        case openProtocolAddressEvent
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
    }

    func setupSubViewEvent() {
        protocolAddressLabel.rx.tapGesture().when(UIGestureRecognizer.State.recognized).asObservable().subscribe(onNext: { [weak self](_) in
            guard let `self` = self else { return }
            self.sendEventWith(Event.openProtocolAddressEvent.rawValue, userinfo: ["address": self.addressURL ?? ""])
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.despositNameViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
