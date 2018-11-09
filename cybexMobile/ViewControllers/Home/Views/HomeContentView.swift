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
        static let sectionHeaderHeight: Double = 73.0
    }
    
    enum SortedByKindAction: String {
        case none
        case nameUp
        case nameDown
        case volUp
        case volDown
        case priceUp
        case priceDown
        case appliesUp
        case appliesDown
    }
    
    var sortedAction: SortedByKindAction = .none {
        didSet {
            if let data = self.data as? [Ticker] {
                self.reloadData = dealWithReloadData(data)
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    var currentBaseIndex = 0 {
        didSet {
            if let data = self.data as? [Ticker] {
                self.reloadData = dealWithReloadData(data)
            }
        }
    }

    var viewType: ViewType = ViewType.homeContent {
        didSet {
            if self.viewType == .comprehensive {
                self.tableView.isScrollEnabled = false
                var buckets = appData.filterPopAssetsCurrency()
                if buckets.count >= 6 {
                    self.reloadData = Array(buckets[0..<6])
                } else {
                    self.reloadData = buckets
                }
            }
        }
    }

    lazy var sectionHeader: HomeSectionHeaderView = {
        let sectionHeader = HomeSectionHeaderView(frame: CGRect(x: 0, y: 0, width: self.width,
                                                                height: CGFloat(Define.sectionHeaderHeight)))
        return sectionHeader
    }()

    var data: Any? {
        didSet {
            if let data = data as? [Ticker] {
                self.reloadData = dealWithReloadData(data)
            }
        }
    }
    
    var reloadData: [Ticker]? {
        didSet{
            if let _ = reloadData {
                self.tableView.reloadData()
            }
        }
    }
    
    func dealWithReloadData(_ sender: [Ticker]) -> [Ticker] {
        let originalData = sender.filter({$0.base == AssetConfiguration.marketBaseAssets[currentBaseIndex]})
        switch self.sortedAction {
        case .none:
            return originalData
        case .nameUp:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstInfo = appData.assetInfo[first.quote], let secondInfo = appData.assetInfo[second.quote] else {return false}
                
                return firstInfo.symbol.filterJade < secondInfo.symbol.filterJade
            })
        case .nameDown:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstInfo = appData.assetInfo[first.quote], let secondInfo = appData.assetInfo[second.quote] else {return false}
                
                return firstInfo.symbol.filterJade > secondInfo.symbol.filterJade
            })
        case .volUp:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstDecimal = first.baseVolume.toDecimal(), let secondDecimal = second.baseVolume.toDecimal() else { return false}
                return firstDecimal < secondDecimal
            })
        case .volDown:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstDecimal = first.baseVolume.toDecimal(), let secondDecimal = second.baseVolume.toDecimal() else { return false}
                return firstDecimal > secondDecimal
            })
        case .priceUp:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstDecimal = first.latest.toDecimal(), let secondDecimal = second.latest.toDecimal() else { return false}
                return firstDecimal < secondDecimal
            })
        case .priceDown:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstDecimal = first.latest.toDecimal(), let secondDecimal = second.latest.toDecimal() else { return false}
                return firstDecimal > secondDecimal
            })
        case .appliesUp:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstDecimal = first.percentChange.toDouble(), let secondDecimal = second.percentChange.toDouble() else { return false}
                return firstDecimal < secondDecimal
            })
        case .appliesDown:
            return originalData.sorted(by: { (first, second) -> Bool in
                guard let firstDecimal = first.percentChange.toDouble(), let secondDecimal = second.percentChange.toDouble() else { return false}
                return firstDecimal > secondDecimal
            })
//        default:
//            return []
//            break
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
        if let data = self.reloadData {
            return data.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: HomePairCell.self), for: indexPath) as? HomePairCell, let result = self.reloadData {
            if self.viewType == .comprehensive {
                cell.cellType = .topGainers
                if indexPath.row < result.count {
                    cell.setup(result[indexPath.row], indexPath: indexPath)
                } else {
                    cell.setup(nil, indexPath: indexPath)
                }
            } else {
                let data = result[indexPath.row]
                cell.setup(data, indexPath: indexPath)
            }
            return cell
        }
        return HomePairCell()
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
    
    @objc func sortedByName(_ data: [String: Any]) {
        guard let kind = data["data"] as? Int else { return }
        switch kind {
        case 0:self.sortedAction = .none
        case 1:self.sortedAction = .nameUp
        case 2:self.sortedAction = .nameDown
        default:
            break
        }
    }
    
    @objc func sortedByPrice(_ data: [String: Any]) {
        guard let kind = data["data"] as? Int else { return }
        switch kind {
        case 0:self.sortedAction = .none
        case 1:self.sortedAction = .priceUp
        case 2:self.sortedAction = .priceDown
        default:
            break
        }
    }
    
    @objc func sortedByApplies(_ data: [String: Any]) {
        guard let kind = data["data"] as? Int else { return }
        switch kind {
        case 0:self.sortedAction = .none
        case 1:self.sortedAction = .appliesUp
        case 2:self.sortedAction = .appliesDown
        default:
            break
        }
    }
    
    @objc func sortedByVol(_ data: [String: Any]) {
        guard let kind = data["data"] as? Int else { return }
        switch kind {
        case 0:self.sortedAction = .none
        case 1:self.sortedAction = .volUp
        case 2:self.sortedAction = .volDown
        default:
            break
        }
    }
}
