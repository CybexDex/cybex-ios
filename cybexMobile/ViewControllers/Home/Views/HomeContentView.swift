//
//  HomeContentView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class HomeContentView: UIView {
    struct Define {
        static let sectionHeaderHeight: Double = 71.0
    }

    @IBOutlet weak var tableView: UITableView!
    var currentBaseIndex = 0 {
        didSet {
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
    }

    var viewType: ViewType = ViewType.homeContent {
        didSet {
            if self.viewType == .comprehensive {
                self.tableView.isScrollEnabled = false
                var buckets = appData.filterPopAssetsCurrency()
                if buckets.count >= 6 {
                    self.data = Array(buckets[0..<6])
                } else {
                    self.data = buckets
                }
            }
        }
    }

    lazy var sectionHeader: HomeSectionHeaderView = {
        let sectionHeader = HomeSectionHeaderView(frame: CGRect(x: 0, y: 0, width: self.width, height: CGFloat(Define.sectionHeaderHeight)))
        return sectionHeader
    }()

    var data: Any? {
        didSet {
            if let _ = data as? [Ticker] {
                self.tableView.reloadData()
            }
        }
    }

    func setup() {
        let cell = String.init(describing: HomePairCell.self)
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
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

extension HomeContentView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewType == .comprehensive {
            return 6
        }

        return appData.filterQuoteAssetTicker(AssetConfiguration.market_base_assets[currentBaseIndex]).filter({ (ticker) -> Bool in
            return ticker.base_volume != "0"
        }).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: HomePairCell.self), for: indexPath) as! HomePairCell
        if self.viewType == .comprehensive {
            cell.cellType = .topGainers
            if let data = self.data as? [Ticker] {
                if indexPath.row < data.count {
                    cell.setup(data[indexPath.row], indexPath: indexPath)
                } else {
                    cell.setup(nil, indexPath: indexPath)
                }
            }
        } else {
            let markets = appData.filterQuoteAssetTicker(AssetConfiguration.market_base_assets[currentBaseIndex]).filter({ (ticker) -> Bool in
                return ticker.base_volume != "0"

            })
            let data = markets[indexPath.row]
            cell.setup(data, indexPath: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.viewType == .comprehensive {
            return nil
        }
        return sectionHeader
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewType == .comprehensive {
            return 0.0
        }
        return CGFloat(Define.sectionHeaderHeight)
    }
}

extension HomeContentView {
    @objc func tagDidSelected(_ data: [String: Any]) {
        if let index = data["selectedIndex"] as? Int {
            self.currentBaseIndex = index
        }
    }
}
