//
//  TradeView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TradeView: UIView {

    enum Event: String {
        case orderbookClicked
        case chooseDecimalNumberEvent
        case switchTradeViewShowType
    }

    enum ShowType: Int {
        case sellOnly = 0
        case buyOnly
        case normal
    }

    @IBOutlet weak var titlePrice: UILabel!
    @IBOutlet weak var titleAmount: UILabel!
    @IBOutlet weak var topAmount: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var bottomAmount: UILabel!
    //    @IBOutlet weak var rmbPrice: UILabel!
    @IBOutlet weak var sells: UIStackView!
    @IBOutlet weak var buies: UIStackView!
    @IBOutlet var items: [TradeLineView]!
    
    @IBOutlet weak var decimalView: UIView!
    @IBOutlet weak var deciLabel: UILabel!
    @IBOutlet weak var deciImgView: UIImageView!

    @IBOutlet weak var showTypeView: UIView!
    @IBOutlet weak var showTypeLabel: UILabel!
    @IBOutlet weak var showTypeImgView: UIImageView!

    var showType: ShowType = .normal {
        didSet {
            sellModels.removeAll()
            buyModels.removeAll()

            switch showType {
            case .buyOnly:
                amount.superview?.isHidden = true
                bottomAmount.superview?.isHidden = true
                topAmount.superview?.isHidden = false
            case .sellOnly:
                amount.superview?.isHidden = true
                topAmount.superview?.isHidden = true
                bottomAmount.superview?.isHidden = false
            case .normal:
                topAmount.superview?.isHidden = true
                bottomAmount.superview?.isHidden = true
                amount.superview?.isHidden = false
            }

            refreshView()
        }
    }
    fileprivate var sellModels: [OrderBookViewModel] = []
    fileprivate var buyModels: [OrderBookViewModel] = []

    var data: Any? {
        didSet {
            refreshView()
        }
    }

    func refreshView() {
        if let data = self.data as? OrderBook {
            let bids = data.bids
            let asks = data.asks

            switch showType {
            case .buyOnly:
                fillBuyOnlyData(data, bids: bids)
            case .sellOnly:
                fillSellOnlyData(data, asks: asks)
            case .normal:
                fillNormalData(data, bids: bids, asks: asks)
            }
        }
    }

    func fillNormalData(_ orderBook:OrderBook, bids: [OrderBook.Order], asks: [OrderBook.Order]) {
        for index in 6...10 {
            let ri = index - 6

            if let sell = sells.viewWithTag(index) as? TradeLineView {
                sell.pricePrecision = orderBook.pricePrecision
                sell.amountPrecision = orderBook.amountPrecision

                if asks.count - 1 >= ri {
                    sell.alpha = 1

                    let maxCount = min(asks.count, 5)

                    let allPercent: Decimal = asks[0...maxCount - 1].compactMap( { $0.volumePercent } ).reduce(0, +)
                    let percent: Decimal = asks[0...ri].compactMap( { $0.volumePercent } ).reduce(0, +)
                    if ri < self.sellModels.count {
                        let viewModel = self.sellModels[ri]
                        viewModel.orderbook.accept(asks[ri])
                        viewModel.percent.accept(percent / allPercent)
                    }
                    else {
                        let model = OrderBookViewModel((asks[ri], percent,true))
                        self.sellModels.insert(model, at: ri)
                        sell.adapterModelToTradeLineView(model)
                    }
                } else {
                    sell.alpha = 0
                }
            }

            if let buy = buies.viewWithTag(index) as? TradeLineView {
                buy.pricePrecision = orderBook.pricePrecision
                buy.amountPrecision = orderBook.amountPrecision
                if bids.count - 1 >= ri {
                    buy.alpha = 1

                    let maxCount = min(bids.count, 5)
                    let allPercent: Decimal = bids[0...maxCount - 1].compactMap( { $0.volumePercent } ).reduce(0, +)
                    let percent: Decimal = bids[0...ri].compactMap( { $0.volumePercent } ).reduce(0, +)
                    if index - 6 < self.buyModels.count {
                        let viewModel = self.buyModels[ri]
                        viewModel.orderbook.accept(bids[ri])
                        viewModel.percent.accept(percent / allPercent)
                    }
                    else {
                        let model = OrderBookViewModel((bids[ri], percent,false))
                        self.buyModels.insert(model, at: ri)
                        buy.adapterModelToTradeLineView(model)
                    }
                } else {
                    buy.alpha = 0
                }
            }
        }
    }

    func fillSellOnlyData(_ orderBook:OrderBook, asks: [OrderBook.Order]) {
        for index in 6...10 {
            if let buy = buies.viewWithTag(16 - index) as? TradeLineView {
                buy.pricePrecision = orderBook.pricePrecision
                buy.amountPrecision = orderBook.amountPrecision
                let ri = index - 6

                if asks.count - 1 >= ri {
                    buy.alpha = 1

                    let maxCount = min(asks.count, 10)
                    let allPercent: Decimal = asks[0...maxCount - 1].compactMap( { $0.volumePercent } ).reduce(0, +)
                    let percent: Decimal = asks[0...ri].compactMap( { $0.volumePercent } ).reduce(0, +)
                    if ri < self.sellModels.count {
                        let viewModel = self.sellModels[ri]
                        viewModel.orderbook.accept(asks[ri])
                        viewModel.percent.accept(percent / allPercent)
                    }
                    else {
                        let model = OrderBookViewModel((asks[ri], percent / allPercent, true))
                        self.sellModels.insert(model, at: ri)
                        buy.adapterModelToTradeLineView(model)
                    }
                } else {
                    buy.alpha = 0
                }
            }
        }

        for index in 6...10 {
            if let sell = sells.viewWithTag(index) as? TradeLineView {
                sell.pricePrecision = orderBook.pricePrecision
                sell.amountPrecision = orderBook.amountPrecision
                let ri = index - 1

                if asks.count - 1 >= ri {
                    sell.alpha = 1

                    let maxCount = min(asks.count, 10)

                    let allPercent: Decimal = asks[0...maxCount - 1].compactMap( { $0.volumePercent } ).reduce(0, +)
                    let percent: Decimal = asks[0...ri].compactMap( { $0.volumePercent } ).reduce(0, +)
                    if index - 1 < self.sellModels.count {
                        let viewModel = self.sellModels[ri]
                        viewModel.orderbook.accept(asks[ri])
                        viewModel.percent.accept(percent / allPercent)
                    }
                    else {
                        let model = OrderBookViewModel((asks[ri], percent / allPercent, true))
                        self.sellModels.insert(model, at: ri)
                        sell.adapterModelToTradeLineView(model)
                    }
                } else {
                    sell.alpha = 0
                }
            }


        }
    }

    func fillBuyOnlyData(_ orderBook:OrderBook, bids: [OrderBook.Order]) {
        for index in 6...10 {
            if let sell = sells.viewWithTag(16 - index) as? TradeLineView {
                sell.pricePrecision = orderBook.pricePrecision
                sell.amountPrecision = orderBook.amountPrecision
                let ri = index - 6

                if bids.count - 1 >= ri {
                    sell.alpha = 1

                    let maxCount = min(bids.count, 10)

                    let allPercent: Decimal = bids[0...maxCount - 1].compactMap( { $0.volumePercent } ).reduce(0, +)
                    let percent: Decimal = bids[0...ri].compactMap( { $0.volumePercent } ).reduce(0, +)
                    if ri < self.buyModels.count {
                        let viewModel = self.buyModels[ri]
                        viewModel.orderbook.accept(bids[ri])
                        viewModel.percent.accept(percent / allPercent)
                    }
                    else {
                        let model = OrderBookViewModel((bids[ri], percent / allPercent, false))
                        self.buyModels.insert(model, at: ri)
                        sell.adapterModelToTradeLineView(model)
                    }
                } else {
                    sell.alpha = 0
                }
            }
        }

        for index in 6...10 {
            if let buy = buies.viewWithTag(index) as? TradeLineView {
                buy.pricePrecision = orderBook.pricePrecision
                buy.amountPrecision = orderBook.amountPrecision
                let ri = index - 1

                if bids.count - 1 >= ri {
                    buy.alpha = 1

                    let maxCount = min(bids.count, 10)
                    let allPercent: Decimal = bids[0...maxCount - 1].compactMap( { $0.volumePercent } ).reduce(0, +)
                    let percent: Decimal = bids[0...ri].compactMap( { $0.volumePercent } ).reduce(0, +)
                    if ri < self.buyModels.count {
                        let viewModel = self.buyModels[ri]
                        viewModel.orderbook.accept(bids[ri])
                        viewModel.percent.accept(percent / allPercent)
                    }
                    else {
                        let model = OrderBookViewModel((bids[ri], percent / allPercent, false))
                        self.buyModels.insert(model, at: ri)
                        buy.adapterModelToTradeLineView(model)
                    }
                } else {
                    buy.alpha = 0
                }
            }
        }
    }
    
    func setAmountAction(_ sender: (Decimal, UIColor), pair: Pair) {
        let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)
        let lastPrice = sender.0.formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)

        var rmbPrice: Decimal = 0
        if let baseAsset = AssetConfiguration.CybexAsset(pair.base) {
            rmbPrice = sender.0 * AssetConfiguration.shared.rmbOf(asset: baseAsset)
        }

        let priceString = sender.0 == 0 ? "--" : lastPrice + handlerRMBLabel(rmbPrice.formatCurrency(digitNum: AppConfiguration.rmbPrecision))
        let priceAttributeString = NSMutableAttributedString(string: priceString,
                                                             attributes: [NSAttributedString.Key.foregroundColor : sender.1])


        if sender.0 != 0 {
            priceAttributeString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14,
                                                                                                weight: UIFont.Weight.medium)],
                                               range: NSMakeRange(0, lastPrice.count))
            priceAttributeString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)],
                                               range: NSMakeRange(lastPrice.count,
                                                                  priceString.count - lastPrice.count))
        }
        else {
            priceAttributeString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14,
                                                                                                weight: UIFont.Weight.medium)],
                                               range: NSMakeRange(0, priceString.count))
        }

        self.amount.attributedText = priceAttributeString
        self.topAmount.attributedText = priceAttributeString
        self.bottomAmount.attributedText = priceAttributeString
    }

    func handlerRMBLabel(_ str: String) -> String {
        if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable, let vc = self.parentViewController?.parent?.parent as? TradeViewController, let context = vc.context, context.pageType == .game {
            return ""
        }

        return "≈¥" + str
    }
    
    func resetImage() {
        deciImgView.image = R.image.ic2()
        showTypeImgView.image = R.image.ic2()
    }

    func setup() {
        if UIScreen.main.bounds.width == 320 {
            self.titlePrice.font = UIFont.systemFont(ofSize: 10)
            self.titleAmount.font = UIFont.systemFont(ofSize: 10)
        }
        
        for item in items {
            item.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                
                self.next?.sendEventWith(Event.orderbookClicked.rawValue, userinfo: ["price": item.price.text ?? "0"])
                
            }).disposed(by: disposeBag)
        }
        
        decimalView.rx.tapGesture().when(GestureRecognizerState.recognized).subscribe(onNext: { [weak self](tap) in
            guard let `self` = self else { return }
            self.deciImgView.image = R.image.ic2Up()
            self.next?.sendEventWith(Event.chooseDecimalNumberEvent.rawValue, userinfo: ["data": self.deciLabel.text ?? "", "self": self.decimalView ?? ""])
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        showTypeView.rx.tapGesture().when(GestureRecognizerState.recognized).subscribe(onNext: { [weak self](tap) in
            guard let `self` = self else { return }
            self.showTypeImgView.image = R.image.ic2Up()
            self.next?.sendEventWith(Event.switchTradeViewShowType.rawValue, userinfo: ["data": self.showTypeLabel.text ?? "", "self": self.showTypeView ?? ""])

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
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
