//
//  TradeHistoryView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class TradeHistoryView: UIView {

    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var sellAmount: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var data: [(Bool, String, String, String, String)]? {
        didSet {
            self.tableView.reloadData()

            updateContentSize()
        }
    }

    // 绑定的数据
    fileprivate var reloadData: [(Bool, String, String, String, String)]? {
        didSet {
        }
    }

    // 重置绑定的数据
    fileprivate func resetReloadData(_ sender: [(Bool, String, String, String, String)]) {

    }

    func setup() {
        let cell = String.init(describing: TradeHistoryCell.self)
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)

    }

    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    func updateContentSize() {
        self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)

        self.performSelector(onMainThread: #selector(self.updateHeight), with: nil, waitUntilDone: false)
    }

    @objc fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let lastView = self.subviews.last?.subviews.last
        return lastView!.top + self.tableView.contentSize.height
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

extension TradeHistoryView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.data?.count)! / 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: TradeHistoryCell.self), for: indexPath) as? TradeHistoryCell {
            cell.setup(self.data?[(indexPath.row + 1) * 2 - 2], indexPath: indexPath)
            return cell
        }
        return TradeHistoryCell()
    }
}
