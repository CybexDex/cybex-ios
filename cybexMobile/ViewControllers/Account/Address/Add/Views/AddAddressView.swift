//
//  AddAddressView.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class AddAddressView: UIView {

    @IBOutlet weak var asset: RechargeItemView!
    @IBOutlet weak var address: AddressItemView!
    @IBOutlet weak var mark: AddressItemView!
    @IBOutlet weak var memo: AddressItemView!
    @IBOutlet weak var addBtn: Button!
    
    var data: Any? {
        didSet {
            if let address = data as? WithdrawAddress {
                self.asset.content.text = address.currency
                self.address.content.text = address.address
                self.memo.content.text = address.memo
            }
            else if let address = data as? TransferAddress {
                self.address.content.text = address.address
                self.mark.content.text = address.name
            }
        }
    }
    
    fileprivate func setup() {
        updateHeight()
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
