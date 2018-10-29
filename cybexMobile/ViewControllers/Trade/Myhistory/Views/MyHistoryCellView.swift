//
//  MyHistoryCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class MyHistoryCellView: UIView {
    
    @IBOutlet weak var asset: UILabel!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var base: UILabel!
    
    @IBOutlet weak var kindL: UILabel!
    @IBOutlet weak var orderAmount: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var orderPrice: UILabel!
    
    @IBOutlet weak var state: UILabel!
    
    var data: Any? {
        didSet {
            if let fillOrder = data as? (FillOrder, time: String) {
                updateUI(fillOrder)
            }
        }
    }
    
    func updateUI(_ orderInfo: (FillOrder, time: String)) {
        let order = orderInfo.0
        if let payInfo = appData.assetInfo[order.pays.assetID], let receiveInfo = appData.assetInfo[order.receives.assetID] {
            // 从首页筛选出交易对
            let result = calculateAssetRelation(assetIDAName: payInfo.symbol.filterJade, assetIDBName: receiveInfo.symbol.filterJade)
            if result.base == payInfo.symbol.filterJade && result.quote == receiveInfo.symbol.filterJade {
                // pay -> base   receive -> quote
                // Buy
                self.asset.text = result.quote
                self.base.text  = "/" + result.base
                self.kindL.text = "BUY"
                self.typeView.backgroundColor = .turtleGreen
                
                let realAmount = getRealAmount(receiveInfo.id, amount: order.receives.amount)
                let paysAmount = getRealAmount(payInfo.id, amount: order.pays.amount)
                self.amount.text = realAmount.string(digits: receiveInfo.precision, roundingMode: .down) + " " + receiveInfo.symbol.filterJade
                self.orderAmount.text = getRealAmount(payInfo.id, amount: order.pays.amount).string(digits: payInfo.precision, roundingMode: .down) +
                    " " + payInfo.symbol.filterJade
                
                self.orderPrice.text = (paysAmount / realAmount).string(digits: payInfo.precision, roundingMode: .down) +
                    " " +  payInfo.symbol.filterJade
                
            } else {
                // SELL   pay -> quote receive -> base
                self.kindL.text = "SELL"
                self.asset.text = result.quote
                self.base.text  = "/" + result.base
                self.typeView.backgroundColor = .reddish
                let realAmount = getRealAmount(payInfo.id, amount: order.pays.amount)
                let receivesAmount = getRealAmount(receiveInfo.id, amount: order.receives.amount)
                let payAmount = getRealAmount(payInfo.id, amount: order.pays.amount)
                self.amount.text = realAmount.string(digits: payInfo.precision, roundingMode: .down) +
                    " " + payInfo.symbol.filterJade
                self.orderAmount.text = receivesAmount.string(digits: receiveInfo.precision, roundingMode: .down) + " " +  receiveInfo.symbol.filterJade
                self.orderPrice.text = (receivesAmount / payAmount).string(digits: receiveInfo.precision, roundingMode: .down) +
                    " " + receiveInfo.symbol.filterJade
            }
            self.time.text = orderInfo.time
        }
    }
    
    func setup() {
        
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
