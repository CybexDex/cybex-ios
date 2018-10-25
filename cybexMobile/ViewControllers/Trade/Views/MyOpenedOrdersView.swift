//
//  MyOpenedOrdersView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class MyOpenedOrdersView: UIView {
    @IBOutlet weak var sectionView: LockupAssetsSectionView!
    @IBOutlet weak var tableView: UITableView!

    enum event: String {
        case cancelOrder
    }

    var data: Any? {
        didSet {
            if let _ = data as? Pair {

                self.tableView.reloadData()
            }
        }
    }

    fileprivate func setup() {
        let name = UINib.init(nibName: String.init(describing: OpenedOrdersCell.self), bundle: nil)
        self.tableView.register(name, forCellReuseIdentifier: String.init(describing: OpenedOrdersCell.self))
        sectionView.totalTitle.locali = R.string.localizable.my_opened_price.key
        sectionView.cybPriceTitle.locali = R.string.localizable.my_opened_filled.key
        self.tableView.tableFooterView = UIView()
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

extension MyOpenedOrdersView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pair = data as? Pair else { return 0 }
        let orderes = UserManager.shared.limitOrder.value?.filter({ (limitorder) -> Bool in
            return (limitorder.sellPrice.base.assetID == pair.base && limitorder.sellPrice.quote.assetID == pair.quote) || (limitorder.sellPrice.base.assetID == pair.quote && limitorder.sellPrice.quote.assetID == pair.base)
        }) ?? []

        if orderes.count == 0 {
            self.showNoData(R.string.localizable.openedorder_nodata.key.localized())
        } else {
            self.hiddenNoData()
        }
        return orderes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OpenedOrdersCell.self), for: indexPath) as! OpenedOrdersCell
        cell.Cell_Type = 0

        guard let pair = data as? Pair else { return cell }
        let orderes = UserManager.shared.limitOrder.value?.filter({ (limitorder) -> Bool in
            return (limitorder.sellPrice.base.assetID == pair.base && limitorder.sellPrice.quote.assetID == pair.quote) || (limitorder.sellPrice.base.assetID == pair.quote && limitorder.sellPrice.quote.assetID == pair.base)
        }) ?? []
        cell.setup(orderes[indexPath.row], indexPath: indexPath)
        return cell
    }
}

extension MyOpenedOrdersView {
    @objc func cancleOrderAction(_ data: [String: Any]) {
        if let index = data["selectedIndex"] as? Int {
            guard let pair = self.data as? Pair else { return  }
            let orderes = UserManager.shared.limitOrder.value?.filter({ (limitorder) -> Bool in
                return (limitorder.sellPrice.base.assetID == pair.base && limitorder.sellPrice.quote.assetID == pair.quote) || (limitorder.sellPrice.base.assetID == pair.quote && limitorder.sellPrice.quote.assetID == pair.base)
            }) ?? []
            let order = orderes[index]
            self.next?.sendEventWith(event.cancelOrder.rawValue, userinfo: ["order": order])
        }
    }
}
