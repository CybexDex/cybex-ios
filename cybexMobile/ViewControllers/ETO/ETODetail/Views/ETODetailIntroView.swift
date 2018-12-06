//
//  ETODetailIntroView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ActiveLabel

@IBDesignable
class ETODetailIntroView: CybexBaseView {

    @IBOutlet weak var downUpButton: UIButton!
    @IBOutlet weak var contentLabel: ActiveLabel!
    @IBOutlet weak var titleLabel: UILabel!

    enum Event: String {
        case ETODetailIntroViewDidClicked
        case downUpBtnClick
        case labelClick
    }

    @IBInspectable
    var title: String = "" {
        didSet {
            titleLabel.locali = title
        }
    }

    var content: String = "" {
        didSet {
            contentLabel.text = content
        }
    }

    func setContentAttribute(contentLabelStr: String, attLabelArray: [String]) {
        for att in attLabelArray {
            let customType = ActiveType.custom(pattern: att)
            contentLabel.enabledTypes.append(customType)
            contentLabel.customize { label in
                label.customColor[customType] = UIColor.steel
                label.configureLinkAttribute = { (type, attributes, isSelected) in
                    var atts = attributes
                    atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                    return atts
                }
                label.handleCustomTap(for: customType, handler: { [weak self](str) in
                    guard let self = self else { return }
                    self.next?.sendEventWith(Event.labelClick.rawValue, userinfo: ["clicklabel": str])
                })
            }
        }
        content = contentLabelStr
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {

    }

    func setupSubViewEvent() {
        downUpButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.downUpButton.isSelected = !self.downUpButton.isSelected
            if self.downUpButton.isSelected == true {
                self.contentLabel.numberOfLines = 0
            } else {
                self.contentLabel.numberOfLines = 3
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETODetailIntroViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }

    deinit {
        log.debug("ETODetailIntroView delloc -- \(self)")
    }
}
