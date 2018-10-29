//
//  TradeHistoryViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift

enum TradeHistoryPageType {
    case market
    case trade
}

class TradeHistoryViewController: BaseViewController {
    
    @IBOutlet weak var historyView: TradeHistoryView!
    
    var coordinator: (TradeHistoryCoordinatorProtocol & TradeHistoryStateManagerProtocol)?
    
    var pageType: TradeHistoryPageType = .market
    
    var pair: Pair? {
        didSet {
            if pair != oldValue {
                self.coordinator?.resetData()
            }
            refreshView()
        }
    }
    
    var data: [(Bool, String, String, String, String)]? {
        didSet {
            if self.historyView != nil {
                self.historyView.data = data
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEvent()
    }
    
    func refreshView() {
        guard let pair = pair, let baseInfo = appData.assetInfo[(pair.base)], let quoteInfo = appData.assetInfo[(pair.quote)] else { return }
        if self.view.width == 320 {
            self.historyView.price.font  = UIFont.systemFont(ofSize: 11)
            self.historyView.amount.font  = UIFont.systemFont(ofSize: 11)
            self.historyView.sellAmount.font  = UIFont.systemFont(ofSize: 11)
            self.historyView.time.font = UIFont.systemFont(ofSize: 11)
        }
        
        self.historyView.price.text  = R.string.localizable.trade_history_price.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
        self.historyView.amount.text  = R.string.localizable.trade_history_amount.key.localized() + "(" + quoteInfo.symbol.filterJade + ")"
        self.historyView.sellAmount.text  = R.string.localizable.trade_history_total.key.localized() + "(" + baseInfo.symbol.filterJade + ")"
        self.historyView.time.text = R.string.localizable.my_history_time.key.localized()
        
        self.coordinator?.fetchData(pair)
    }
    
    func setupEvent() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: { [weak self] _ in
            guard let `self` = self else { return }
            self.refreshView()
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func configureObserveState() {
        self.coordinator!.state.property.data.asObservable()
            .subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                
                self.convertToData()
                self.coordinator?.updateMarketListHeight(500)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
    }
    
    func convertToData() {
        if let data = self.coordinator?.state.property.data.value {
            var showData: [(Bool, String, String, String, String)] = []
            
            for itemData in data {
                let curData = itemData
                
                let pay = curData[0]
                let receive = curData[1]
                let time = curData[2].stringValue
                
                let baseInfo = appData.assetInfo[pair!.base]!
                let quoteInfo = appData.assetInfo[pair!.quote]!
                let basePrecision = pow(10, baseInfo.precision.double)
                let quotePrecision = pow(10, quoteInfo.precision.double)
                
                if pay["asset_id"].stringValue == pair?.base {
                    let quoteVolume = Double(receive["amount"].stringValue)! / quotePrecision
                    let baseVolume = Double(pay["amount"].stringValue)! / basePrecision
                    
                    let price = baseVolume / quoteVolume
                    let tradePrice = price.tradePrice()
                    
                    showData.append((false,
                                     tradePrice.price,
                                     quoteVolume.suffixNumber(digitNum: 10 - tradePrice.pricision),
                                     baseVolume.suffixNumber(digitNum: tradePrice.pricision),
                                     time.dateFromISO8601!.string(withFormat: "HH:mm:ss")))
                } else {
                    let quoteVolume = Double(pay["amount"].stringValue)! / quotePrecision
                    let baseVolume = Double(receive["amount"].stringValue)! / basePrecision
                    
                    let price = baseVolume / quoteVolume
                    
                    let tradePrice = price.tradePrice()
                    showData.append((true,
                                     tradePrice.price,
                                     quoteVolume.suffixNumber(digitNum: 10 - tradePrice.pricision),
                                     baseVolume.suffixNumber(digitNum: tradePrice.pricision),
                                     time.dateFromISO8601!.string(withFormat: "HH:mm:ss")))
                }
                
            }
            self.data = showData
        }
    }
}
extension TradeHistoryViewController: TradePair {
    var pariInfo: Pair {
        get {
            return self.pair!
        }
        set {
            self.pair = newValue
        }
    }
    
    func refresh() {
        refreshView()
    }
}
