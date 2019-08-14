//
//  MyHistoryCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class MyHistoryCellView: UIView {
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var kindL: UILabel!
    @IBOutlet weak var asset: UILabel!
    @IBOutlet weak var base: UILabel!
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var averagePrice: UILabel!
    @IBOutlet weak var orderPrice: UILabel!

    @IBOutlet weak var orderAmount: UILabel!
    @IBOutlet weak var amount: UILabel!


    var data: Any? {
        didSet {
            if let model = data as? ViewModel {
                updateUI(model)
            }
        }
    }

    func updateUI(_ vm: ViewModel) {
        kindL.text = vm.isBuy ? "BUY" : "SELL"
        typeView.backgroundColor = vm.isBuy ? .turtleGreen : .reddish

        self.asset.text = vm.quote
        self.base.text = "/" + vm.base
        self.time.text = vm.time

        self.averagePrice.text = vm.middleTop
        self.orderPrice.text = vm.middleBottom
        self.orderAmount.text = vm.rightTop
        self.amount.text = vm.rightBottom


        if vm.isCanceled {
            self.base.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
        }
        else {
            self.base.theme_textColor = [UIColor.steel.hexString(true), UIColor.steel.hexString(true)]
        }
        typeView.alpha = vm.isCanceled ? 0.5 : 1
        kindL.alpha = vm.isCanceled ? 0.5 : 1
        asset.alpha = vm.isCanceled ? 0.5 : 1
        base.alpha = vm.isCanceled ? 0.5 : 1
        averagePrice.alpha = vm.isCanceled ? 0.5 : 1
        orderAmount.alpha = vm.isCanceled ? 0.5 : 1

        time.alpha = vm.isCanceled ? 0.3 : 1
        orderPrice.alpha = vm.isCanceled ? 0.3 : 1
        amount.alpha = vm.isCanceled ? 0.3 : 1
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

extension MyHistoryCellView {
    struct ViewModel {
        var oid: String = ""
        var isBuy: Bool
        var isCanceled: Bool
        var quote: String
        var base: String
        var time: String

        var middleTop: String
        var middleBottom: String
        var rightTop: String
        var rightBottom: String

        static func makeViewModelFrom(data: LimitOrderStatus) -> ViewModel {
            let isBuy = data.isBuyOrder()
            let pair = data.getPair()
            let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)

            let time = data.createTime.string(withFormat: "MM/dd HH:mm:ss")

            var average = data.getAveragePrice().toReal().formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)

            let price = data.getPrice().toReal().formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)

            var dealAmountString = ""

            if let dealAmount = isBuy ? data.receivedAmount : data.soldAmount {
                if dealAmount == 0  {
                    dealAmountString = "--"
                    average = "--"
                }
                else {
                    dealAmountString = data.getAveragePrice().quote.volume().suffixNumber(digitNum: tradePrecision.book.amount.int!, padZero: true) + " " + pair.quote.symbol
                }
            }

            let amountString = data.getPrice().quote.volume().suffixNumber(digitNum: tradePrecision.book.amount.int!, padZero: true) + " " + pair.quote.symbol

            return ViewModel(oid: data.orderId,
                             isBuy: isBuy,
                             isCanceled: data.canceledAmount > 0,
                             quote: pair.quote.symbol,
                             base: pair.base.symbol,
                             time: time,
                             middleTop: average,
                             middleBottom: price,
                             rightTop: dealAmountString,
                             rightBottom: amountString)
        }

        static func makeViewModelFrom(data: FillOrder, orginTime: String) -> ViewModel {
            let isBuy = data.isBuyOrder()
            let pair = data.getPair()
            let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)


            let time = Formatter.iso8601.date(from: orginTime)!.string(withFormat: "MM/dd HH:mm:ss")

            let price = data.getPrice().toReal().formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)

            var dealAmount: String
            var totalAmount: String

            if pair.quote == data.pays.assetID {
                dealAmount = data.pays.volume().suffixNumber(digitNum: tradePrecision.book.amount.int!, padZero: true)
                totalAmount = data.receives.volume().suffixNumber(digitNum: tradePrecision.book.total.int!, padZero: true) + " " + pair.base.symbol
            }
            else {
                dealAmount = data.receives.volume().suffixNumber(digitNum: tradePrecision.book.amount.int!, padZero: true)
                totalAmount = data.pays.volume().suffixNumber(digitNum: tradePrecision.book.total.int!, padZero: true) + " " + pair.base.symbol
            }

            let feeAmount = data.fee.volumeString()  + " " + data.fee.assetID.symbol

            return ViewModel(oid: "",
                             isBuy: isBuy,
                             isCanceled: false,
                             quote: pair.quote.symbol,
                             base: pair.base.symbol,
                             time: time,
                             middleTop: price,
                             middleBottom: dealAmount,
                             rightTop: totalAmount,
                             rightBottom: feeAmount)
        }
    }
}
