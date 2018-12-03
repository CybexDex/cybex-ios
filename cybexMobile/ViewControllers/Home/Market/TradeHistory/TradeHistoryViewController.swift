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

struct TradeHistoryViewModel {
    var pay: Bool
    var price: String
    var quoteVolume: String
    var baseVolume: String
    var time: String
}

class TradeHistoryViewController: BaseViewController {

    @IBOutlet weak var historyView: TradeHistoryView!

    var coordinator: (TradeHistoryCoordinatorProtocol & TradeHistoryStateManagerProtocol)?

    var pageType: TradeHistoryPageType = .market

    var pair: Pair? {
        didSet {
            if pair != oldValue {
                self.coordinator?.resetData(pair!)
            }
            refreshView()
        }
    }

    var data: [TradeHistoryViewModel]? {
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification),
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
            guard let `self` = self else { return }
            self.refreshView()
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: LCLLanguageChangeNotification),
                                                  object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func configureObserveState() {
        self.coordinator!.state.data.asObservable()
            .subscribe(onNext: {[weak self] (data) in
                guard let `self` = self else { return }

                self.data = data
                self.coordinator?.updateMarketListHeight(500)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

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
