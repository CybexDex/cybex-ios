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
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var detailView: ETODetailIntroView!
    @IBOutlet weak var introView: ETODetailIntroView!
    @IBOutlet weak var websiteView: ETODetailIntroView!
    @IBOutlet weak var headerView: ETODetailHeaderView!
    
    
    fileprivate var action : ETOJoinButtonAction?
    enum Event:String {
        case ETODetailViewDidClicked
        case inputCode
        case crowdPage
        case icoapePage
        case unlockPage
        
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
        getJoinButtonState()
        
        getWhiteListView.rightIcon.image = R.image.icwhitelist()
        getWhiteListView.name.textColor = UIColor.pastelOrange
    }
    
    func getJoinButtonState() {
        let clause = ETOManager.shared.getClauseState()
        let state = ETOManager.shared.getETOJoinButtonState()
        
        switch state {
        case .normal(let title, let style, let action):
            stateView.isHidden = false
            updateStateView(clauseState:clause, title: title, style: style, action: action)
        case .disable(let title, let style):
            stateView.isHidden = false
            updateStateView(clauseState:clause, title: title, style: style, action: nil)
        case .notShow:
            stateView.isHidden = true
        }
    }
    
    func updateStateView(clauseState: ETOClauseState, title: String, style: ETOJoinButtonStyle, action: ETOJoinButtonAction?) {
        stateButton.titleString = title
        updateClauseState(clauseState: clauseState)
        updateJoinButton(style: style)
        self.action = action
    }
    
    func updateJoinButton(style: ETOJoinButtonStyle) {
        switch style {
        case .normal:
            stateButton.titleColor = UIColor.white
            stateButton.gradientStartColor = UIColor.peach
            stateButton.gradientEndColor = UIColor.maincolor
            stateButton.alpha = 1
            stateButton.isUserInteractionEnabled = true
        case .wait:
            stateButton.titleColor = UIColor.pastelOrange
            stateButton.btn_borderColor = UIColor.peach
            stateButton.btn_borderWidth = 1
            stateButton.bgColor = UIColor.clear
            stateButton.alpha = 1
            stateButton.isUserInteractionEnabled = false
        case .notPassed:
            stateButton.titleColor = UIColor.white
            stateButton.btn_borderColor = UIColor.steel50
            stateButton.btn_borderWidth = 1
            stateButton.bgColor = UIColor.clear
            stateButton.alpha = 1
            stateButton.isUserInteractionEnabled = false
        case .disable:
            stateButton.titleColor = UIColor.white
            stateButton.gradientStartColor = UIColor.steel
            stateButton.gradientEndColor = UIColor.steel
            stateButton.alpha = 0.5
            stateButton.isUserInteractionEnabled = false
        }
    }
    
    func updateClauseState(clauseState: ETOClauseState) {
        switch clauseState {
        case .normal:
            updateAgreeBtnImg(normal: R.image.icUnselected16Px()!, selected: R.image.icSelected24Px()!, highlighted: R.image.icSelected24Px()!)
            agreeButton.isUserInteractionEnabled = true
            updateClauseViewHidden(isHidden: false)
        case .checkedAndImmutable:
            updateAgreeBtnImg(normal: R.image.icSelected124Px()!, selected: R.image.icSelected124Px()!, highlighted: R.image.icSelected124Px()!)
            agreeButton.isUserInteractionEnabled = false
            updateClauseViewHidden(isHidden: false)
        case .notShow:
            updateClauseViewHidden(isHidden: true)
        }

    }
    
    func updateAgreeBtnImg(normal: UIImage, selected: UIImage, highlighted: UIImage) {
        agreeButton.setImage(normal, for: UIControlState.normal)
        agreeButton.setImage(highlighted, for: UIControlState.highlighted)
        agreeButton.setImage(selected, for: UIControlState.selected)
    }
    
    func updateClauseViewHidden(isHidden: Bool) {
        stateLabel.isHidden = isHidden
        agreeButton.isHidden = isHidden
    }
    
    func setupSubViewEvent() {
        stateButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] touch in
            guard let `self` = self else { return }
            guard let action =  self.action else { return }
            self.next?.sendEventWith(action.rawValue, userinfo: [:])
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        agreeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] touch in
            guard let `self` = self else { return }
            self.agreeButton.isSelected = !self.agreeButton.isSelected
            self.next?.sendEventWith(Event.crowdPage.rawValue, userinfo: ["data": self.data ?? "", "self": self])

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETODetailViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

