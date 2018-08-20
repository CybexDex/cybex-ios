//
//  AddressHomeTableViewCellViewView.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class AddressHomeTableViewCellViewView: UIView {
    
    @IBOutlet weak var sectionView: SectionCornerViewView!
    
    var data: Any? {
        didSet {
        
        }
    }
    
    func appendView() {
        let v = NormalCellView(frame: CGRect.zero)
        v.index = 0
        v.name_locali = R.string.localizable.withdraw_address.key
        v.height(54)
        sectionView.stackView.addArrangedSubview(v)
        
        let v2 = NormalCellView(frame: CGRect.zero)
        v2.index = 1
        v2.name_locali = R.string.localizable.transfer_account.key
        v2.isShowLineView = false
        sectionView.stackView.addArrangedSubview(v2)
    }
    
    fileprivate func setup() {
        updateHeight()
        appendView()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
    }
    
    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView?.bottom ?? 0
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
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        insertSubview(view, at: 0)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
