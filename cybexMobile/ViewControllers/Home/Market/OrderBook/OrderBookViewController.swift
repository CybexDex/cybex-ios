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

enum orderbook_type : Int{
    case contentView = 1
    case tradeView
}

class OrderBookViewController: BaseViewController {
    
    var coordinator: (OrderBookCoordinatorProtocol & OrderBookStateManagerProtocol)?
    
    var contentView : OrderBookContentView!
    var tradeView : TradeView!
    var VC_TYPE : Int = orderbook_type.contentView.rawValue
    var pair:Pair? {
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
    func setupUI(){
        if VC_TYPE == orderbook_type.contentView.rawValue{
            contentView = OrderBookContentView(frame: .zero)
            self.view.addSubview(contentView)
            contentView.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }else{
            tradeView = TradeView(frame:self.view.bounds)
            self.view.addSubview(tradeView)
            
            tradeView.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            setupEvent()
        }
        setTopTitle()
    }
    
    func setTopTitle(){
        guard let pair = self.pair, let base_info = app_data.assetInfo[pair.base],let quote_info = app_data.assetInfo[pair.quote] else { return }
        if VC_TYPE == orderbook_type.tradeView.rawValue{
            self.tradeView.titlePrice.text = R.string.localizable.orderbook_price.key.localized() + "(" + base_info.symbol.filterJade + ")"
            self.tradeView.titleAmount.text = R.string.localizable.orderbook_amount.key.localized() + "(" + quote_info.symbol.filterJade + ")"
        }else{
            self.contentView.buyPrice.text =  R.string.localizable.orderbook_buy_price.key.localized() + "(" + base_info.symbol.filterJade + ")"
            self.contentView.buyVolume.text = R.string.localizable.orderbook_volume.key.localized() + "(" + quote_info.symbol.filterJade + ")"
            self.contentView.sellPrice.text = R.string.localizable.orderbook_sell_price.key.localized() + "(" + base_info.symbol.filterJade + ")"
            self.contentView.sellVolume.text = R.string.localizable.orderbook_volume.key.localized() + "(" + quote_info.symbol.filterJade + ")"
        }
    }
    
    func setupEvent(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] notification in
            guard let `self` = self else { return }
            self.setTopTitle()
            
        })
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func configureObserveState() {
        self.coordinator!.state.property.data.asObservable().skip(1).distinctUntilChanged()
            .subscribe(onNext: {[weak self] (s) in
                guard let `self` = self else { return }
                if let parentVC = self.parent?.parent as? TradeViewController {
                    if parentVC.isLoading() {
                        parentVC.endLoading()
                    }
                }
                if self.VC_TYPE == 1{
                    self.contentView.data = s
                    self.contentView.tableView.reloadData()
                    self.contentView.tableView.isHidden = false
                    self.coordinator?.updateMarketListHeight(500)
                }else{
                    if self.coordinator?.state.property.pair.value == self.pair{
                        self.tradeView.data = s
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func showMarketPrice() {
        guard let pair = pair , let _ = AssetConfiguration.market_base_assets.index(of: pair.base) else { return }
        
        if let selectedIndex = app_data.filterQuoteAsset(pair.base).index(where: { (bucket) -> Bool in
            return bucket.quote == pair.quote
        }) {
            let markets = app_data.filterQuoteAsset(pair.base)
            let data = markets[selectedIndex]
            
            let matrix = getCachedBucket(data)
            
            self.tradeView.amount.text = matrix.price.tradePrice.price
            self.tradeView.amount.textColor = matrix.incre.color()
            
            if matrix.price == "" {
                self.tradeView.rmbPrice.text  = "≈¥"
                return
            }
            let (eth,cyb) = changeToETHAndCYB(pair.quote)
            if eth == "0" && cyb == "0"{
                self.tradeView.rmbPrice.text  = "≈¥"
            }else if (eth == "0"){
                if let cyb_eth = changeCYB_ETH().toDouble(),cyb_eth != 0{
                    let eth_count = cyb.toDouble()! / cyb_eth
                    if eth_count * app_data.eth_rmb_price == 0{
                        self.tradeView.rmbPrice.text  = "≈¥"
                    }else{
                        self.tradeView.rmbPrice.text  = "≈¥" + (eth_count * app_data.eth_rmb_price).formatCurrency(digitNum: 2)
                    }
                }else{
                    self.tradeView.rmbPrice.text  = "≈¥"
                }
            }else{
                if eth.toDouble()! * app_data.eth_rmb_price == 0 {
                    self.tradeView.rmbPrice.text  = "≈¥"
                }else{
                    self.tradeView.rmbPrice.text  = "≈¥" + (eth.toDouble()! * app_data.eth_rmb_price).formatCurrency(digitNum: 2)
                }
            }
        }
    }
}

extension OrderBookViewController : TradePair{
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


