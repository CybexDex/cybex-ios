//
//  OrderBookCellView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class OrderBookCellView: UIView {
    @IBOutlet weak var buyPrice: UILabel!
    @IBOutlet weak var buyVolume: UILabel!

    @IBOutlet weak var sellPrice: UILabel!
    @IBOutlet weak var sellVolume: UILabel!

    @IBOutlet weak var leftBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var rightBoxWidth: NSLayoutConstraint!

    var data: Any? {
        didSet {
            guard let showData = data as? (OrderBook.Order?, OrderBook.Order?, Decimal?, Decimal?) else { return }

            if let bid = showData.0 {
                self.buyPrice.text = bid.price
                self.buyVolume.text = bid.volume
                self.leftBoxWidth = self.leftBoxWidth.changeMultiplier(multiplier: showData.2!.cgfloat())
            } else {
                self.buyPrice.text = ""
                self.buyVolume.text = ""
                self.leftBoxWidth = self.leftBoxWidth.changeMultiplier(multiplier: 0.001)
            }

            //      print("left:\(self.leftBoxWidth.multiplier)  ")
            if let ask = showData.1 {
                self.sellPrice.text = ask.price
                self.sellVolume.text = ask.volume
                self.rightBoxWidth = self.rightBoxWidth.changeMultiplier(multiplier: showData.3!.cgfloat())
            } else {
                self.sellPrice.text = ""
                self.sellVolume.text = ""
                self.rightBoxWidth = self.rightBoxWidth.changeMultiplier(multiplier: 0.001)
            }
            //      print("right:\(self.rightBoxWidth.multiplier)  ")

        }
    }

    fileprivate func setup() {

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
