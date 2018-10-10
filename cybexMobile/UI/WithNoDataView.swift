//
//  withNoDataView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/1.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class WithNoDataView: UIView {
    
    @IBOutlet weak var notice: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var noticeContairner: NSLayoutConstraint!
    
    var notice_word : String? {
        didSet {
            if let notice_word = notice_word{
                notice.text = notice_word
            }
        }
    }
    
    var icon_name : String? {
        didSet {
            if let icon_name = icon_name {
                icon.image = UIImage.init(named: icon_name)
            }
        }
    }
    
    func setup(){
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric,height: dynamicHeight())
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
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}
