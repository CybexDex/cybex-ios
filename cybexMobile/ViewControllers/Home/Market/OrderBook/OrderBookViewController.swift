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

enum OrderbookType: Int {
    case contentView = 1
    case tradeView
}

class OrderBookViewController: BaseViewController {

    var coordinator: (OrderBookCoordinatorProtocol & OrderBookStateManagerProtocol)?
    var contentView: OrderBookContentView!
    var tradeView: TradeView!
    var vcType: Int = OrderbookType.contentView.rawValue
    var pair: Pair? {
        didSet {
            guard let pair = pair, oldValue != pair else {
                return
            }
            self.coordinator?.resetData(pair)

            if self.vcType == OrderbookType.contentView.rawValue {
                self.fetchOrderBookData(pair, count: 20)
            }
            else {
                if let oldPair = oldValue, let coor = self.coordinator {
                    coor.unSubscribe(oldPair, depth: coor.state.depth.value, count: 5)
                }
                self.fetchOrderBookData(pair, count: 5)
            }
            if self.tradeView != nil || self.contentView != nil {
                setTopTitle()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.coordinator?.orderbookServerConnect()
    }
    func fetchOrderBookData(_ pair: Pair,count: Int) {
        guard let tradePairPrecision = TradeConfiguration.shared.tradePairPrecisions.value[pair] else {
            TradeConfiguration.shared.tradePairPrecisions.asObservable().subscribe(onNext: { [weak self](data) in
                guard let self = self, let selfPair = self.pair, selfPair == pair, let result = data[pair] else { return }
                self.coordinator?.subscribe(pair, depth: result.price, count: count)
                if self.vcType == OrderbookType.tradeView.rawValue {
                    self.tradeView.deciLabel.text = R.string.localizable.trade_decimal_number.key.localizedFormat(result.price)
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
            return
        }
        if self.vcType == OrderbookType.tradeView.rawValue {
            self.tradeView.deciLabel.text = R.string.localizable.trade_decimal_number.key.localizedFormat(tradePairPrecision.price)
        }
        self.coordinator?.subscribe(pair, depth: tradePairPrecision.price, count: count)
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
        self.coordinator!.state.data.asObservable().skip(1).distinctUntilChanged()
            .subscribe(onNext: {[weak self] (result) in
                guard let self = self else { return }
                if let parentVC = self.parent?.parent as? TradeViewController {
                    if parentVC.isLoading() {
                        parentVC.endLoading()
                    }
                }
                if self.vcType == OrderbookType.contentView.rawValue {
                    if let pair = self.pair, let precision = TradeConfiguration.shared.tradePairPrecisions.value[pair], var order = result {
                        order.pricePrecision = precision.price
                        order.amountPrecision = precision.amount
                        self.contentView.data = order
                        self.contentView.tableView.reloadData()
                        self.contentView.tableView.isHidden = false
                        self.coordinator?.updateMarketListHeight(500)
                    }
                } else {
                    if result == nil {
                        self.tradeView.data = OrderBook(bids: [], asks: [])
                        return
                    }
                    if let pair = self.pair,
                        let precision = TradeConfiguration.shared.tradePairPrecisions.value[pair],
                        var order = result,
                        let coor = self.coordinator {
                        order.pricePrecision = coor.state.depth.value
                        order.amountPrecision = precision.amount
                        self.tradeView.data = order
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        if vcType == OrderbookType.tradeView.rawValue {
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

    func refresh() {
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
}

extension OrderBookViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.tradeView.resetDecimalImage()
        guard let superVC = popoverPresentationController.presentedViewController as? RecordChooseViewController else {
            return true
        }
        superVC.dismiss(animated: false, completion: nil)
        return false
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension OrderBookViewController: RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String) {
        if let depthString = info.components(separatedBy: " ").first,
            let depth = depthString.int,
            let pair = self.pair ,let coor = self.coordinator {
            coor.unSubscribe(pair, depth: coor.state.depth.value, count: coor.state.count)
            coor.subscribe(pair, depth: depth, count: 5)
        }
        self.tradeView.resetDecimalImage()
        sender.dismiss(animated: false, completion: nil)
    }
}
