//
//  OrderBookContentView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class OrderBookContentView: UIView {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var buyPrice: UILabel!
    @IBOutlet weak var buyVolume: UILabel!
    @IBOutlet weak var sellPrice: UILabel!
    @IBOutlet weak var sellVolume: UILabel!

    var data: Any? {
        didSet {
            self.tableView.reloadData()
        }
    }

    fileprivate func setup() {

        if UIScreen.main.bounds.width == 320 {
            self.buyPrice.font = UIFont.systemFont(ofSize: 10)
            self.buyVolume.font = UIFont.systemFont(ofSize: 10)
            self.sellPrice.font = UIFont.systemFont(ofSize: 10)
            self.sellVolume.font = UIFont.systemFont(ofSize: 10)
        }

        self.buyPrice.locali =  R.string.localizable.orderbook_buy_price.key
        self.buyVolume.locali = R.string.localizable.orderbook_volume.key
        self.sellPrice.locali = R.string.localizable.orderbook_sell_price.key
        self.sellVolume.locali = R.string.localizable.orderbook_volume.key

        let cell = String.init(describing: OrderBookCell.self)
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)  }

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
extension OrderBookContentView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.data as? OrderBook {
            return min(20, max(data.asks.count, data.bids.count))
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OrderBookCell.self), for: indexPath) as? OrderBookCell {
            if let data = self.data as? OrderBook {
                let asks = data.asks
                let bids = data.bids

                let maxAsks = asks.count >= 20 ? 19 : asks.count - 1
                let maxBids = bids.count >= 20 ? 19 : bids.count - 1

                let maxAsksPercent  = asks[optional:maxAsks]?.volumePercent
                let maxBidsPercent  = bids[optional:maxBids]?.volumePercent

                let asksPercent = asks[optional:indexPath.row]?.volumePercent
                let bidsPercent = bids[optional:indexPath.row]?.volumePercent

                var percentBuy: Double?
                var percentSell: Double?

                if let maxAsksPercent = maxAsksPercent, let asksPercent = asksPercent {
                    percentBuy = asksPercent / maxAsksPercent
                }
                if let maxBidsPercent = maxBidsPercent, let bidsPercent = bidsPercent {
                    percentSell = bidsPercent / maxBidsPercent
                }

                cell.setup((bids[optional:indexPath.row], asks[optional:indexPath.row], percentSell, percentBuy), indexPath: indexPath)
            }
            return cell
        }
        return OrderBookCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
