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
    @IBOutlet weak var price: UILabel!

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
            if let order = data as? LimitOrder {
                if self.basePriceView.isHidden == false {
                    self.basePrice.text = "--"
                }

                if order.isBuy {
                    self.orderType.openedStatus = 0

                    if let quoteInfo = appData.assetInfo[order.sellPrice.quote.assetID], let baseInfo = appData.assetInfo[order.sellPrice.base.assetID] {
                        quote.text = quoteInfo.symbol.filterJade
                        base.text = "/" + baseInfo.symbol.filterJade

                        let basePrice = getRealAmount(order.sellPrice.base.assetID,
                                                      amount: order.sellPrice.base.amount) /
                            getRealAmount(order.sellPrice.quote.assetID,
                                          amount: order.sellPrice.quote.amount)

                        let baseAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.forSale)

                        var quoteAmount: Decimal!
                        if order.forSale == order.sellPrice.base.amount {
                            quoteAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
                        } else {
                            quoteAmount = baseAmount / basePrice
                        }

                        self.amount.text = quoteAmount.string(digits: quoteInfo.precision, roundingMode: .down) + " " + quoteInfo.symbol.filterJade
                        if self.basePriceView.isHidden == false {
                            self.price.text =  baseAmount.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                            self.basePrice.text = basePrice.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                        } else {
                            self.price.text = basePrice.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                        }
                    }
                } else {
                    self.orderType.openedStatus = 1
                    if let quoteInfo = appData.assetInfo[order.sellPrice.base.assetID], let baseInfo = appData.assetInfo[order.sellPrice.quote.assetID] {
                        self.quote.text = quoteInfo.symbol.filterJade
                        self.base.text = "/" + baseInfo.symbol.filterJade

                        let basePrice = getRealAmount(order.sellPrice.quote.assetID,
                                                      amount: order.sellPrice.quote.amount) /
                            getRealAmount(order.sellPrice.base.assetID,
                                          amount: order.sellPrice.base.amount)
                        let quoteAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.forSale)

                        var baseAmount: Decimal!
                        if order.forSale == order.sellPrice.base.amount {
                            baseAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
                        } else {
                            baseAmount = basePrice * quoteAmount
                        }

                        self.amount.text = quoteAmount.string(digits: quoteInfo.precision, roundingMode: .down) + " " +  quoteInfo.symbol.filterJade
                        if self.basePriceView.isHidden == false {
                            self.price.text = baseAmount.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                            self.basePrice.text = basePrice.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                        } else {
                            self.price.text = basePrice.string(digits: baseInfo.precision, roundingMode: .down) + " " + baseInfo.symbol.filterJade
                        }
                    }
                }
            }
        }
    }

    fileprivate func setup() {
        cancleOrder.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.cancleOrder.next?.sendEventWith(CancleOrder.cancleOrderAction.rawValue, userinfo: ["selectedIndex": self.selectedIndex?.row ?? 0])
        }).disposed(by: disposeBag)

        //    self.lineView.backgroundColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.paleGrey

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
