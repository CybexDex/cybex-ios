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
    var VCType: Int = OrderbookType.contentView.rawValue
    var pair: Pair? {
        didSet {
            guard let pair = pair else { return }
            if self.tradeView != nil {
                //        self.coordinator?.resetData(pair)
                showMarketPrice()
            }
            self.coordinator?.fetchData(pair)
            if self.tradeView != nil || self.contentView != nil {
                setTopTitle()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    func setupUI() {
        if VCType == OrderbookType.contentView.rawValue {
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
        guard let pair = self.pair, let baseInfo = appData.assetInfo[pair.base], let quoteInfo = appData.assetInfo[pair.quote] else { return }
        if VCType == OrderbookType.tradeView.rawValue {
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
            guard let `self` = self else { return }
            self.setTopTitle()
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func configureObserveState() {
        self.coordinator!.state.property.data.asObservable().skip(1).distinctUntilChanged()
            .subscribe(onNext: {[weak self] (result) in
                guard let `self` = self else { return }
                if let parentVC = self.parent?.parent as? TradeViewController {
                    if parentVC.isLoading() {
                        parentVC.endLoading()
                    }
                }
                if self.VCType == 1 {
                    self.contentView.data = result
                    self.contentView.tableView.reloadData()
                    self.contentView.tableView.isHidden = false
                    self.coordinator?.updateMarketListHeight(500)
                } else {
                    if self.coordinator?.state.property.pair.value == self.pair {
                        self.tradeView.data = result
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func showMarketPrice() {
        guard let pair = pair, let _ = AssetConfiguration.marketBaseAssets.index(of: pair.base) else { return }
        if let selectedIndex = appData.filterQuoteAssetTicker(pair.base).index(where: { (ticker) -> Bool in
            return ticker.quote == pair.quote
        }) {
            let tickers = appData.filterQuoteAssetTicker(pair.base)
            let data = tickers[selectedIndex]
            
            self.tradeView.amount.text = data.latest.tradePrice.price
            self.tradeView.amount.textColor = data.incre.color()
            
            if data.latest == "0" {
                self.tradeView.rmbPrice.text  = "≈¥"
                return
            }
            
            self.tradeView.rmbPrice.text = "≈¥" + getAssetRMBPrice(pair.quote, base: pair.base).string(digits: 2, roundingMode: .down)
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
        guard let pair = pair else { return }
        if self.tradeView != nil {
            //      self.coordinator?.resetData(pair)
            
            showMarketPrice()
        }
        self.coordinator?.fetchData(pair)
    }
}
