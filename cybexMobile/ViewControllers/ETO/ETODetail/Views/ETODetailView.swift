//
//  ETODetailView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import SwiftTheme

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
//        detailView.content = "项目名称：ICO CLUB CHAIN\n代币名称：CLUB\n兑换比例：1 ETH=1667 CLUB\nETO时间：2018/08/03  17:25:00\n结束时间：2018/09/03  18:25:00\n开放交易时间：2018/08/03  17:25:00\n发币时间：实时\n使用币种：ETH"
//        introView.content = "Herdius 是具有前瞻性的跨链交互解决方案。Herdius 用一个私钥打通所有的区块链，只需要一个 Herdius 账户和配套的 Herdius 钱包，无需特定的代币，用户就能够跨链使用各种去中心化应用，触达各种生态系统。Herdius 独特的同态秘钥派生技术能够保障我们建立一个全球化的流动资金池，打通各家中心化、去中心化交易所、资金池。为了能够应对这么高的交易吞吐量，Herdius 采用了一种改良的、非联邦型的 DPoS 共识机制，其中 HER 代币起到了质押货币的作用。Herdius 所采用的共识机制使得我们可以采用一种称为区块叠加区块（Blocks-on-blocks，BoB）的技术，构建一条可以垂直扩展的区块链。用户可以质押任意金额的 HER 代币，然后参与到 Herdius 链上的交易验证中。通过质押所挣得的手续费与抵押代币的多少、交易量成正比。"
//        websiteView.setContentAttribute(contentLabelStr: "官网：https://www.notion.so/d3198dd4ba934f6ba4f7164d49ac9ded?v=f43339b8776244e4bd95cc11f63d9a8d\n白皮书：https://blog.csdn.net/qxuewei/article/details/51095192\n项目详情：haha3", attLabelArray: ["https://www.notion.so/d3198dd4ba934f6ba4f7164d49ac9ded?v=f43339b8776244e4bd95cc11f63d9a8d","https://blog.csdn.net/qxuewei/article/details/51095192","haha3"])
        headerView.setupUI()
        
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
            if ThemeManager.currentThemeIndex == 0 {
                stateButton.titleColor = UIColor.white
            } else {
                stateButton.titleColor = UIColor.darkTwo
            }
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
            agreeButton.isSelected = false
            updateClauseViewHidden(isHidden: false)
        case .checkedAndImmutable:
            updateAgreeBtnImg(normal: R.image.icSelected124Px()!, selected: R.image.icSelected124Px()!, highlighted: R.image.icSelected124Px()!)
            agreeButton.isUserInteractionEnabled = false
            agreeButton.isSelected = true
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
            if self.agreeButton.isHidden == false, self.agreeButton.isSelected == false {
                return
            }
            self.next?.sendEventWith(action.rawValue, userinfo: [:])
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        agreeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] touch in
            guard let `self` = self else { return }
            self.agreeButton.isSelected = !self.agreeButton.isSelected
//            self.next?.sendEventWith(Event.crowdPage.rawValue, userinfo: ["data": self.data ?? "", "self": self])

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETODetailViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
    
    @objc func clickCellView(_ data: [String: Any]) {
        if let data = self.data as? ETOProjectViewModel, let model = data.projectModel {
            self.next?.sendEventWith("clickCellView", userinfo: ["data": Localize.currentLanguage() == "en" ? model.adds_whitelist__lang_en : model.adds_whitelist])
        }
    }
}

