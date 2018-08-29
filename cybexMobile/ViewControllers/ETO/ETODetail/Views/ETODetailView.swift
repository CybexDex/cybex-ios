//
//  ETODetailView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETODetailView: BaseView {
    
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var stateButton: LGButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var getWhiteListView: NormalCellView!
    
    
    enum Event:String {
        case ETODetailViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        getWhiteListView.name.textColor = UIColor.pastelOrange
    }
    
    func setupSubViewEvent() {
        agreeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] touch in
            guard let `self` = self else { return }
            self.agreeButton.isSelected = !self.agreeButton.isSelected
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETODetailViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

