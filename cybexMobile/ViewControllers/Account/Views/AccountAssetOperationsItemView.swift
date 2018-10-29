//
//  AccountAssetOperationsItemView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Localize_Swift
import SwiftTheme

class AccountAssetOperationsItemView: UIView {
    var data: Any? {
        didSet {
            self.setup()
        }
    }
    
    @IBOutlet weak var nameL: UILabel!
    
    func setup() {
        self.subviews.last?.shadowColor   = ThemeManager.currentThemeIndex == 0 ? .black10 : .steel20
        self.subviews.last?.shadowOffset  = CGSize(width: 0, height: 8.0)
        self.subviews.last?.shadowRadius  = 4.0
        self.subviews.last?.shadowOpacity = 1.0
    }
    
    var viewType: Int = 0 {
        didSet {
            changeViewType()
        }
    }
    
    func changeViewType() {
        nameL.localizedText = viewType == 0 ? R.string.localizable.openedTitle.key.localizedContainer() : R.string.localizable.lockupAssetsTitle.key.localizedContainer()
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
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}
