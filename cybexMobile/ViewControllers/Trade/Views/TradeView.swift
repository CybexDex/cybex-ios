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
    }

    @IBOutlet weak var titlePrice: UILabel!

    @IBOutlet weak var titleAmount: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var rmbPrice: UILabel!

    @IBOutlet weak var sells: UIStackView!
    @IBOutlet weak var buies: UIStackView!

    @IBOutlet var items: [TradeLineView]!

    var data: Any? {
        didSet {
            if let data = data as? OrderBook {
                let bids = data.bids
                let asks = data.asks

                for index in 6...10 {
                    if let sell = sells.viewWithTag(index) as? TradeLineView {
                        if asks.count - 1 >= (index - 6) {
                            sell.isBuy = true
                            sell.alpha = 1

                            let percent: Decimal = asks[0...index - 6].compactMap( { $0.volumePercent } ).reduce(0, +)
                            sell.data = (asks[index - 6], percent)

                        } else {
                            sell.alpha = 0
                        }
                        if let buy = buies.viewWithTag(index) as? TradeLineView {
                            if bids.count - 1 >= (index - 6) {
                                sell.isBuy   = false
                                buy.alpha = 1

                                let percent = bids[0...index - 6].compactMap( { $0.volumePercent } ).reduce(0, +)

                                buy.data     = (bids[index - 6], percent)
                            } else {
                                buy.alpha = 0
                            }
                        }
                    }
                }
            }
        }
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
