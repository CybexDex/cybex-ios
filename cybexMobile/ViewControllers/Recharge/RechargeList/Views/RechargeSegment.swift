//
//  RechargeSegment.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import RxSwift

class RechargeSegment: UIView {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    enum Event: String {
        case segmentTouch
    }
    
    @IBAction func segmentTouch(_ sender: UISegmentedControl) {
        self.next?.sendEventWith(Event.segmentTouch.rawValue, userinfo: ["selectedIndex": sender.selectedSegmentIndex])
    }
    
    fileprivate func setup() {
        
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
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    
}
