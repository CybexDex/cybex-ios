//
//  TradeItemView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Kingfisher
import Localize_Swift
import SwiftTheme

class TradeItemView: UIView {
    
    var data: Any? {
        didSet {
            if let data = data as? Trade, let info = appData.assetInfo[data.id] {
                
                self.icon.kf.setImage(with: URL(string: AppConfiguration.SERVER_ICONS_BASE_URLString + data.id.replacingOccurrences(of: ".", with: "_") + "_grey.png"))
                if info.symbol.filterJade == "NKN"{
                    print("URL : \(AppConfiguration.SERVER_ICONS_BASE_URLString + data.id.replacingOccurrences(of: ".", with: "_") + "_grey.png"))")
                }
                name.text = info.symbol.filterJade
                if let balances = UserManager.shared.balances.value {
                    for balance in balances {
                        if balance.assetType == data.id, getRealAmount(balance.assetType, amount: balance.balance).doubleValue != 0 {
                            amount.text = getRealAmount(balance.assetType, amount: balance.balance).string(digits: info.precision, roundingMode: .down)
                            return
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var arrow: UIImageView!
    fileprivate func setup() {
        
        //      self.arrow.image = ThemeManager.currentThemeIndex == 0 ? R.image.icArrowLight24Px() : R.image.icArrowDark24Px()
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }
    
    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.bottom
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }
    
    fileprivate func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib     = UINib.init(nibName: nibName, bundle: bundle)
        if let view    = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
}
