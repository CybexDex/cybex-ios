//
//  ExchangeView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class ExchangeView: UIView {
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var historUpDown: UIButton!
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var isMoveMarketTrades: Bool = false
    
    var data: Any? {
        didSet {
            
        }
    }
    
    @IBAction func marketTradesUpDown(_ sender: UIButton) {
        sender.transform = CGAffineTransform(rotationAngle: isMoveMarketTrades == false ? 0 : CGFloat(Double.pi))
        if isMoveMarketTrades {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        } else {
            self.scrollView.contentOffset = CGPoint(x: 0, y: self.titleView.y)
        }
        self.isMoveMarketTrades = !self.isMoveMarketTrades
    }
    
    fileprivate func setup() {
        self.historUpDown.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
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
