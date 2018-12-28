//
//  EvaView.swift
//  cybexMobile
//
//  Created KevinLi on 12/26/18.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import TinyConstraints
import SwiftTheme

@IBDesignable
class EvaView: CybexBaseView {
    @IBOutlet weak var projectDesc: BaseLabel!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var evaIcon: UIImageView!
    @IBOutlet weak var projectDetails: BaseLabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var hypeScoreLabel: UILabel!
    @IBOutlet weak var riskScoreLabel: UILabel!
   
    @IBOutlet weak var expectationLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var icoTokenSupplyLabel: UILabel!
    @IBOutlet weak var tokenPriceLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var scoreBackground: UIImageView!
    enum Event:String {
        case evaViewDidClicked
    }
        
    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        bottomMargin = 16
        
        if ThemeManager.currentThemeIndex == 0 {
            scoreBackground.image = R.image.img_score_dark()
        } else {
            scoreBackground.image = R.image.img_score_white()
        }
        
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.evaViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
