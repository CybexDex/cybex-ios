//
//  ETOCrowdViewView.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETOCrowdView: BaseView {
    
    @IBOutlet weak var gridView: GridContentView!
    @IBOutlet weak var titleTextView: TitleTextfieldView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var actionButton: LGButton!
    @IBOutlet weak var descLabel: BaseLabel!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var itemViews:[ETOCrowdGridItemView]!
    
    enum Event:String {
        case ETOCrowdViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
        self.gridView.datasource = self
    
        self.titleTextView.textField.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
        self.titleTextView.gapView.isHidden = true
        self.titleTextView.titleLabel.locali = R.string.localizable.transfer_quantity.key
        self.actionButton.locali = R.string.localizable.eto_join.key
        self.actionButton.bgColor = UIColor.steel
//        self.actionButton.isEnabled = false
        
        self.titleTextView.unitLabel.text = R.string.localizable.eto_available.key.localizedFormat("1.666", "ETH")
        
        let accountName = StyleNames.bold_12_20.tagText("test1")
        self.descLabel.text = """
        • You will participate in the ETO by your ETH balance in your CYBEX account, and the process may consume certain fees.
        • The assets of this project will be deposited to your account (\(accountName)) after successful subscription.
        • Your final subscription will be subject to the verification by the project holder. You can check through "ETO Project History". When circumstances like personal hard cap exceeded or project.Quota oversubscription happens, the unconfirmed excess quota will be refunded to relevant CYBEX accounts when project ETO ends.
        •    The final ETO participation result takes time to be confirmed. Please wait patiently. If you have any questions, please contact our community assistant through WeChat account: CybexServiceA.
        """
        
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETOCrowdViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension ETOCrowdView: GridContentViewDataSource {
    func itemsForView(_  view: GridContentView) -> [UIView] {
        let titles = [
            R.string.localizable.eto_personal_cap,
            R.string.localizable.eto_subscription_unit,
            R.string.localizable.eto_remaining,
            R.string.localizable.eto_min_subscription,
            R.string.localizable.eto_subscribed
        ]
        
        let views = Array(0...4).map({ (index) -> ETOCrowdGridItemView in
            let item = ETOCrowdGridItemView()
            item.titleLabel.locali = titles[index].key
            item.valueLabel.text = "\(index) ETH"
            item.lineView.isHidden = index == 4
            return item
        })
        
        itemViews = views
        return views
    }
    
    @objc func lineGapForView(_ view: GridContentView) -> CGFloat {
        return 0
    }
    
    @objc func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 2
    }
    
    @objc func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat {
        return 69
    }
}
