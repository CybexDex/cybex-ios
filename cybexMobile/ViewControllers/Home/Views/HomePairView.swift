//
//  HomePairView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Kingfisher

@IBDesignable
class HomePairView: UIView {

    enum Event: String {
        case cellClicked
    }

    @IBOutlet weak var rankingLabel: UILabel!

    @IBOutlet weak var asset2: UILabel!

    @IBOutlet weak var volume: UILabel!

    @IBOutlet weak var price: UILabel!

    @IBOutlet weak var bulking: UILabel!

    @IBOutlet weak var asset1: UILabel!
    @IBOutlet weak var rbmL: UILabel!
    @IBOutlet weak var highLowContain: UIView!

    @IBOutlet weak var icon: UIImageView!

    var base: String!
    var quote: String!
    var data: Any? {
        didSet {
            guard let ticker = data as? Ticker, let baseInfo = appData.assetInfo[ticker.base], let quoteInfo = appData.assetInfo[ticker.quote] else { return }
            self.asset2.text =  quoteInfo.symbol.filterJade
            self.asset1.text = "/" + baseInfo.symbol.filterJade
            let url = AppConfiguration.ServerIconsBaseURLString + ticker.quote.replacingOccurrences(of: ".", with: "_") + "_grey.png"
            self.icon.kf.setImage(with: URL(string: url))
            self.volume.text = ticker.baseVolume.suffixNumber(digitNum: 2)
            self.price.text = ticker.latest.formatCurrency(digitNum: baseInfo.precision)
            self.bulking.text = (ticker.incre == .greater ? "+" : "") + ticker.percentChange.formatCurrency(digitNum: 2) + "%"

            self.highLowContain.backgroundColor = ticker.incre.color()
            if let change = ticker.percentChange.toDouble(), change > 1000 {
                self.bulking.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
            } else {
                self.bulking.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            }

            let price = getAssetRMBPrice(ticker.quote, base: ticker.base)

            self.rbmL.text = price == 0 ? "-" : "≈¥" + "\(price)".formatCurrency(digitNum: 2)
        }
    }

    func replaceIconToLabel() {
        if let index = self.store["index"] as? Int {
            self.icon.isHidden = true
            self.rankingLabel.isHidden = false
            if index < 3 {
                self.rankingLabel.backgroundColor = UIColor.turtleGreen
            } else {
                self.rankingLabel.backgroundColor = UIColor.steel50
            }
            self.rankingLabel.text = "\(index + 1)"
        }
    }

    fileprivate func setup() {
        self.isUserInteractionEnabled = true
        self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }

            self.next?.sendEventWith(Event.cellClicked.rawValue, userinfo: ["index": self.store["index"] ?? []])

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

}
