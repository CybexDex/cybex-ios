//
//  ETODetailIntroView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETODetailIntroView: BaseView {
    
    @IBOutlet weak var downUpButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    enum Event:String {
        case ETODetailIntroViewDidClicked
        case downUpBtnClick
    }
    
    @IBInspectable
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
//    
//    @IBInspectable
//    var Theme1TitleColor: UIColor = UIColor.white {
//        didSet {
//            titleLabel.textColor = Theme1TitleColor
//        }
//    }
//    
//    @IBInspectable
//    var Theme2TitleColor: UIColor = UIColor.white {
//        didSet {
//            titleLabel.textColor = Theme2TitleColor
//        }
//    }
    
    var content: String = "" {
        didSet {
            contentLabel.attributedText = content.set(style: StyleNames.address.rawValue)
        }
    }
    
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        
    }
    
    func setupSubViewEvent() {
        downUpButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] touch in
            guard let `self` = self else { return }
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
}
