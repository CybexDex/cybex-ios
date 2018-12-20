//
//  OpenedOrdersView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class OpenedOrdersView: UIView {

    @IBOutlet weak var orderType: OpenedOrdersStatesView!
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var base: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var basePriceView: UIView!
    @IBOutlet weak var basePrice: UILabel!

    @IBOutlet weak var cancleOrder: UIView!
    @IBOutlet weak var cancleL: UILabel!
    @IBOutlet weak var cancleImg: UIImageView!
    @IBOutlet weak var lineView: UIView!

    enum CancleOrder: String {
        case cancleOrderAction
    }

    var selectedIndex: IndexPath?
    var data: Any? {
        didSet {
            if let order = data as? LimitOrderStatus {
                let pair = order.getPair()
                let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)
                self.quote.text = pair.quote.symbol
                self.base.text = "/" + pair.base.symbol
                self.progressLabel.text = order.decimalProgress().formatCurrency(digitNum: AppConfiguration.percentPrecision) + "%"
                self.timeLabel.text = order.createTime.string(withFormat: "yyyy-MM-dd HH:mm:ss")
                
                self.basePrice.text = order.getPrice().toReal().formatCurrency(digitNum: tradePrecision.price) + " " + pair.base.symbol
                if order.isBuyOrder() {
                    self.orderType.openedStatus = 0
                    self.amount.text = AssetHelper.getRealAmount(pair.quote,
                                                                 amount: order.receivedAmount.string).formatCurrency(digitNum: tradePrecision.amount) + "/" +
                        AssetHelper.getRealAmount(pair.quote,
                                                  amount: order.amountToReceive.string).formatCurrency(digitNum: tradePrecision.amount) + " " + pair.base.symbol
                    self.progressLabel.textColor = self.orderType.buyColor
                }
                else {
                    self.orderType.openedStatus = 1
                    self.progressLabel.textColor = self.orderType.sellColor
                    self.amount.text = AssetHelper.getRealAmount(pair.quote,
                                                                 amount: order.soldAmount.string).formatCurrency(digitNum: tradePrecision.amount) + "/" +
                        AssetHelper.getRealAmount(pair.quote,
                                                  amount: order.amountToSell.string).formatCurrency(digitNum: tradePrecision.amount) + " " + pair.quote.symbol
                }
            }
        }
    }

    fileprivate func setup() {
        cancleOrder.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.cancleOrder.next?.sendEventWith(CancleOrder.cancleOrderAction.rawValue, userinfo: ["selectedIndex": self.selectedIndex?.row ?? 0])
        }).disposed(by: disposeBag)
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

    func setupData(_ data: Any?, indexPath: IndexPath) {
        self.data = data
        self.selectedIndex = indexPath
    }
}
