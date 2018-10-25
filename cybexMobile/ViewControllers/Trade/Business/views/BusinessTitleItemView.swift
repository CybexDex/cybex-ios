//
//  BusinessTitleItemView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class BusinessTitleItemView: UIView {
    enum event: String {
        case cellClicked
    }

    @IBOutlet weak var paris: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var total: UILabel!
    var selectedIndex: Int?

    var data: Any? {
        didSet {
            guard let ticker = data as? Ticker, let base_info = app_data.assetInfo[ticker.base], let quote_info = app_data.assetInfo[ticker.quote] else { return }
            self.paris.text = quote_info.symbol.filterJade + "/" + base_info.symbol.filterJade
            if ticker.latest == "0" {
                self.total.text = "-"
                self.change.text = "-"
                return
            }

            self.total.text = " " + ticker.quote_volume.suffixNumber(digitNum: 2)
            self.change.text = (ticker.incre == .greater ? "+" : "") + ticker.percent_change.formatCurrency(digitNum: 2) + "%"
            if let change = ticker.percent_change.toDouble(), change > 1000 {
                self.change.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
            } else {
                self.change.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            }
            self.change.textColor = ticker.incre.color()
        }
    }

    func setup() {
        self.isUserInteractionEnabled = true
        self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            if let ticker = self.data as? Ticker {
                self.next?.sendEventWith(event.cellClicked.rawValue, userinfo: ["info": Pair(base: ticker.base, quote: ticker.quote), "index": self.selectedIndex ?? 0])
            }
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
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
