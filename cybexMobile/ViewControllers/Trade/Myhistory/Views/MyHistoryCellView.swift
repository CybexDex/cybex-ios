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
    
    var data : Any? {
        didSet{
            if let fillOrder = data as? (FillOrder,time:String) {
                updateUI(fillOrder)
            }
        }
    }
    
    func updateUI(_ orderInfo: (FillOrder,time:String)) {
        let order = orderInfo.0
        
        if let payInfo = app_data.assetInfo[order.pays.assetID] ,let receiveInfo = app_data.assetInfo[order.receives.assetID]{
            // 从首页筛选出交易对
            let result = calculateAssetRelation(assetID_A_name: payInfo.symbol.filterJade, assetID_B_name: receiveInfo.symbol.filterJade)
            if result.base == payInfo.symbol.filterJade && result.quote == receiveInfo.symbol.filterJade{
                // pay -> base   receive -> quote
                // Buy
                self.asset.text = result.quote
                self.base.text  = "/" + result.base
                self.kindL.text = "BUY"
                self.typeView.backgroundColor = .turtleGreen
                self.amount.text = getRealAmount(receiveInfo.id, amount:order.receives.amount).string(digits: receiveInfo.precision,roundingMode:.down) + " " + receiveInfo.symbol.filterJade
                self.orderAmount.text = getRealAmount(payInfo.id, amount: order.pays.amount).string(digits: payInfo.precision,roundingMode:.down) + " " + payInfo.symbol.filterJade
                
                self.orderPrice.text = (getRealAmount(payInfo.id, amount: order.pays.amount) / getRealAmount(receiveInfo.id, amount:order.receives.amount)).string(digits: payInfo.precision,roundingMode:.down) + " " + payInfo.symbol.filterJade
                
            }else{
                // SELL   pay -> quote receive -> base
                self.kindL.text = "SELL"
                self.asset.text = result.quote
                self.base.text  = "/" + result.base
                self.typeView.backgroundColor = .reddish
                self.amount.text = getRealAmount(payInfo.id, amount: order.pays.amount).string(digits: payInfo.precision,roundingMode:.down) + " " + payInfo.symbol.filterJade
                self.orderAmount.text = getRealAmount(receiveInfo.id, amount: order.receives.amount).string(digits: receiveInfo.precision,roundingMode:.down) + " " +  receiveInfo.symbol.filterJade
                self.orderPrice.text = (getRealAmount(receiveInfo.id, amount: order.receives.amount) / getRealAmount(payInfo.id, amount: order.pays.amount)).string(digits: receiveInfo.precision,roundingMode:.down) + " " +  receiveInfo.symbol.filterJade
            }
            self.time.text = orderInfo.time
        }
    }
    
    func setup(){
        
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
        let nibName = String(describing:type(of:self))
        let nib = UINib.init(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
