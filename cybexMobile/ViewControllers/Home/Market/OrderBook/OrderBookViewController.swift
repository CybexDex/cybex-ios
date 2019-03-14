//
//  OrderBookViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import TinyConstraints
import SwiftyJSON
import Localize_Swift
import XLPagerTabStrip

enum OrderbookType: Int {
    case contentView = 1
    case tradeView
}

class OrderBookViewController: BaseViewController {
    var coordinator: (OrderBookCoordinatorProtocol & OrderBookStateManagerProtocol)?
    var contentView: OrderBookContentView!
    var tradeView: TradeView!
    var vcType: Int = OrderbookType.contentView.rawValue
    var pair: Pair?

    override func viewDidLoad() {
        setupUI()

        super.viewDidLoad()
        self.coordinator?.updateMarketListHeight(600)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if vcType == OrderbookType.contentView.rawValue {
            fetchData()
        }
        else {
            self.coordinator?.updateMarketListHeight(600)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if vcType == OrderbookType.contentView.rawValue {
            disappear()
        }
    }

    func fetchData() {
        guard let pair = pair else { return }

        if self.vcType == OrderbookType.contentView.rawValue {
            self.fetchOrderBookData(pair, count: 20)
        }
        else {
            self.fetchOrderBookData(pair, count: 10)
        }
        if self.tradeView != nil || self.contentView != nil {
            setTopTitle()
        }
    }

    func fetchOrderBookData(_ pair: Pair,count: Int) {
        guard let oldDepth = self.coordinator?.state.depth.value else { return }

        guard let tradePairPrecision = TradeConfiguration.shared.tradePairPrecisions.value[pair] else {
            TradeConfiguration.shared.tradePairPrecisions.asObservable().subscribe(onNext: { [weak self](data) in
                guard let self = self,
                    let selfPair = self.pair,
                    selfPair == pair,
                    let result = data[pair] else { return }

                self.coordinator?.subscribe(pair, depth: oldDepth == 0 ? result.price : oldDepth, count: count)

                if self.vcType == OrderbookType.tradeView.rawValue {
                    self.tradeView.deciLabel.text = R.string.localizable.trade_decimal_number.key.localizedFormat(result.price)
                }

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            return
        }
        if self.vcType == OrderbookType.tradeView.rawValue {
            self.tradeView.deciLabel.text = R.string.localizable.trade_decimal_number.key.localizedFormat(tradePairPrecision.price)
        }
        self.coordinator?.subscribe(pair, depth:  oldDepth == 0 ? tradePairPrecision.price : oldDepth, count: count)
    }

    func setupUI() {
        if vcType == OrderbookType.contentView.rawValue {
            contentView = OrderBookContentView(frame: .zero)
            self.view.addSubview(contentView)
            contentView.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        } else {
            tradeView = TradeView(frame: self.view.bounds)
            self.view.addSubview(tradeView)
            tradeView.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            setupEvent()
        }
        setTopTitle()
    }

    func refreshData() {
        guard let result = self.coordinator?.state.data.value, let parentVC = self.parent as? ExchangeViewController ,let grandVC = parentVC.parent as? TradeViewController else {
            self.tradeView.data = OrderBook(bids: [], asks: [])
            return
        }

        if grandVC.isLoading() {
            grandVC.endLoading()
        }

        if parentVC.type.rawValue == grandVC.selectedIndex {
            self.tradeView.data = result
        }
    }

    func setTopTitle() {
        guard let pair = self.pair,
            let baseInfo = appData.assetInfo[pair.base],
            let quoteInfo = appData.assetInfo[pair.quote] else { return }
        if vcType == OrderbookType.tradeView.rawValue {
            self.tradeView.titlePrice.text = R.string.localizable.orderbook_price.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
            self.tradeView.titleAmount.text = R.string.localizable.orderbook_amount.key.localized() + "(" + quoteInfo.symbol.filterJade + ")"
        } else {
            self.contentView.buyPrice.text =  R.string.localizable.orderbook_buy_price.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
            self.contentView.buyVolume.text = R.string.localizable.orderbook_volume.key.localized() + "(" + quoteInfo.symbol.filterJade + ")"
            self.contentView.sellPrice.text = R.string.localizable.orderbook_sell_price.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
            self.contentView.sellVolume.text = R.string.localizable.orderbook_volume.key.localized() + "(" + quoteInfo.symbol.filterJade + ")"
        }
    }

    func switchShowType(_ type: TradeView.ShowType) {
        let titles = [R.string.localizable.orderbook_show_type_1.key,
                      R.string.localizable.orderbook_show_type_2.key,
                      R.string.localizable.orderbook_show_type_3.key]
        tradeView.showTypeLabel.locali = titles[type.rawValue]
        self.tradeView.showType = type
    }

    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] _ in
            guard let self = self else { return }
            self.setTopTitle()
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }

    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().distinctUntilChanged()
            .subscribe(onNext: {[weak self] (result) in
                guard let self = self else { return }

                if self.vcType == OrderbookType.contentView.rawValue {
                    if let result = result {
                        self.contentView.data = result
                        self.contentView.tableView.reloadData()
                        self.contentView.tableView.isHidden = false
                    }
                } else {
                    self.refreshData()
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        if vcType == OrderbookType.tradeView.rawValue {
            self.coordinator?.state.showTypeIndex.asObservable().skip(1).subscribe(onNext: {[weak self] (index) in
                guard let self = self else { return }
                self.switchShowType(TradeView.ShowType(rawValue: index) ?? .normal)
            }).disposed(by: disposeBag)

            self.coordinator?.state.lastPrice.asObservable().skip(1).subscribe(onNext: { [weak self](result) in
                guard let self = self, let pair = self.pair else { return }

                self.tradeView.setAmountAction(result, pair: pair)

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

            self.coordinator?.state.depth.asObservable().skip(1).subscribe(onNext: { [weak self](result) in
                guard let self = self else { return }

                self.tradeView.deciLabel.text = R.string.localizable.trade_decimal_number.key.localizedFormat(result)

                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil) { [weak self](notification) in
                guard let self = self, let coor = self.coordinator else { return }
                self.tradeView.deciLabel.text = R.string.localizable.trade_decimal_number.key.localizedFormat(coor.state.depth.value)
            }
        }
    }
}

extension OrderBookViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }

    func resetView() {
        guard let coor = self.coordinator ,let oldPair = self.coordinator?.state.pair.value else {
            return
        }
        coor.unSubscribe(oldPair, depth: coor.state.depth.value, count: 10)
        coor.resetData(oldPair)

        self.coordinator?.switchShowType(2)
    }

    func appear() {
        refreshData()
        fetchData()
    }

    func disappear() {
        self.coordinator?.disconnect()
    }
}

extension OrderBookViewController {
    @objc func chooseDecimalNumberEvent(_ data: [String: Any]) {
        guard let text = data["data"] as? String, text.count != 0, let senderView = data["self"] as? UIView else {
            return
        }
        guard let coor = self.coordinator, let pair = self.pair else { return }
        guard let tradePairPrecision = TradeConfiguration.shared.tradePairPrecisions.value[pair] else {
            self.coordinator?.openDecimalNumberVC(senderView, maxDecimal: coor.state.depth.value, selectedDecimal: coor.state.depth.value, senderVC: self)
            return
        }
        self.coordinator?.openDecimalNumberVC(senderView, maxDecimal: tradePairPrecision.price, selectedDecimal: coor.state.depth.value, senderVC: self)
    }

    @objc func switchTradeViewShowType(_ data: [String: Any]) {
        guard let text = data["data"] as? String, text.count != 0, let senderView = data["self"] as? UIView else {
            return
        }
        self.coordinator?.openChooseTradeViewShowTypeVC(senderView, selectedIndex: tradeView.showType.rawValue, senderVC: self)
    }
}

extension OrderBookViewController {
    override func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.tradeView.resetImage()
        return true
    }
}

extension OrderBookViewController: RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String, index: Int) {
        if sender.typeIndex == .orderbook {
            if let depthString = info.components(separatedBy: " ").first,
                let depth = depthString.int,
                let pair = self.pair ,let coor = self.coordinator {
                coor.unSubscribe(pair, depth: coor.state.depth.value, count: coor.state.count)
                coor.subscribe(pair, depth: depth, count: 10)
            }

        } else if sender.typeIndex == .tradeShowType {
            self.coordinator?.switchShowType(index)
        }

        self.tradeView.resetImage()
        sender.dismiss(animated: false, completion: nil)
    }
}

extension OrderBookViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: R.string.localizable.mark_order_book.key.localized())
    }
}
