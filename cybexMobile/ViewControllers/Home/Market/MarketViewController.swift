//
//  MarketViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Localize_Swift
import ReSwift
import RxSwift
import SwiftTheme
import UIKit

extension NSNotification.Name {
    static let SpecialPairDidClicked = Notification.Name("SpecialPairDidClicked")
    static let SpecialPairDidCanceled = Notification.Name("SpecialPairDidCanceled")

}

class MarketViewController: BaseViewController {
    @IBOutlet var pageTitleView: DNSPageTitleView!
    @IBOutlet var pageContentView: DNSPageContentView!

    @IBOutlet var pageContentViewHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var pairListView: PairListHorizantalView!

    @IBOutlet var detailView: PairDetailView!
    @IBOutlet var kLineView: CBKLineView!

    @IBOutlet var marketDetailView: PairDetailView!

    @IBOutlet weak var rechargeView: PairRechargeView!

    @IBOutlet weak var rechargeHeight: NSLayoutConstraint!

    var rechargeShowType = PairRechargeView.show_type.show.rawValue
    var currentBaseIndex: Int = 0
    var kLineSpecial = false
    var canExchange = false

    var timeGap: Candlesticks = .oneDay {
        didSet {
            kLineView.timeGap = timeGap
            CBConfiguration.sharedConfiguration.main.timeLineType = CBTimeLineType(rawValue: Int(timeGap.rawValue))!
        }
    }

    var resetKLinePosition: Bool = true

    var indicator: Indicator = .ma {
        didSet {
            switch indicator {
            case .ma:
                CBConfiguration.sharedConfiguration.main.indicatorType = .MA([7, 14, 21])

            case .ema:
                CBConfiguration.sharedConfiguration.main.indicatorType = .EMA([7, 14])

            case .macd:
                CBConfiguration.sharedConfiguration.main.indicatorType = .MACD
                self.pageContentViewHeight.constant = 300
            case .boll:
                CBConfiguration.sharedConfiguration.main.indicatorType = .BOLL(7)
            case .none:
                break
            }
        }
    }

    var curIndex: Int = 0
    var coordinator: (MarketCoordinatorProtocol & MarketStateManagerProtocol)?

    lazy var pair: Pair = {
        Pair(base: self.ticker.base, quote: self.ticker.quote)
    }()

    lazy var ticker: Ticker = {
        let market = self.tickers[self.curIndex]
        return market
    }()

    lazy var tickers: [Ticker] = {
        let markets = appData.filterQuoteAssetTicker(AssetConfiguration.marketBaseAssets[currentBaseIndex]).filter({ (ticker) -> Bool in
            return ticker.baseVolume != "0"
        })
        return markets
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rechargeView.showType = self.rechargeShowType
        if self.rechargeShowType == PairRechargeView.show_type.hidden.rawValue {
            rechargeHeight.constant = 0
        } else {
            rechargeHeight.constant = 56
        }
        setupNotificatin()
        setupEvent()
        var quote_name = ""
        var base_name = ""

        if let quote_info = appData.assetInfo[ticker.quote], let base_info = appData.assetInfo[ticker.base] {
            quote_name = quote_info.symbol.filterJade
            base_name = base_info.symbol.filterJade
        }

        title = quote_name + "/" + base_name
        view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        automaticallyAdjustsScrollViewInsets = false
        marketDetailView.base_name = base_name
        marketDetailView.quote_name = quote_name

        setupPageView()

        startLoading()
        refreshDetailView()
        fetchKlineData()
    }

    func setupNotificatin() {
        NotificationCenter.default.addObserver(forName: .SpecialPairDidClicked, object: nil, queue: nil) {[weak self] (notifi) in
            guard let `self` = self else { return }
            self.kLineSpecial = true
            self.detailView.data = notifi.userInfo?["klineModel"]
        }

        NotificationCenter.default.addObserver(forName: .SpecialPairDidCanceled, object: nil, queue: nil) {[weak self] (_) in
            guard let `self` = self else { return }
            self.kLineSpecial = false
            self.refreshDetailView()
        }
    }

    func setupEvent() {
        self.rechargeView.buy.button.isUserInteractionEnabled = true
        self.rechargeView.sell.button.isUserInteractionEnabled = true
        self.rechargeView.buy.button.addTarget(self, action: #selector(buy), for: .touchUpInside)
        self.rechargeView.sell.button.addTarget(self, action: #selector(sell), for: .touchUpInside)
    }

    func setupPageView() {
        let style = DNSPageStyle()
        style.titleViewBackgroundColor = UIColor.clear
        style.isShowCoverView = false
        style.bottomLineColor = #colorLiteral(red: 1, green: 0.6386402845, blue: 0.3285836577, alpha: 1)
        style.bottomLineHeight = 2
        style.isShowBottomLine = true
        style.titleColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)
        style.titleSelectedColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : #colorLiteral(red: 0.1399003565, green: 0.1798574626, blue: 0.2467218637, alpha: 1)
        style.titleFont = UIFont.systemFont(ofSize: 14)

        // 设置标题内容
        let titles = [R.string.localizable.mark_order_book.key.localized(), R.string.localizable.mark_trade_history.key.localized()]

        // 设置默认的起始位置
        let startIndex = 0

        // 对titleView进行设置
        pageTitleView.titles = titles
        pageTitleView.style = style
        pageTitleView.currentIndex = startIndex

        // 最后要调用setupUI方法
        pageTitleView.setupUI()

        // 创建每一页对应的controller
        let childViewControllers: [BaseViewController] = coordinator!.setupChildViewControllers(pair)

        // 对contentView进行设置
        pageContentView.childViewControllers = childViewControllers
        pageContentView.startIndex = startIndex
        pageContentView.style = style

        // 最后要调用setupUI方法
        pageContentView.setupUI()
        pageContentView.collectionView.panGestureRecognizer.require(toFail: AppConfiguration.shared.appCoordinator.curDisplayingCoordinator().rootVC.interactivePopGestureRecognizer!)

        // 让titleView和contentView进行联系起来
        pageTitleView.delegate = pageContentView
        pageContentView.delegate = pageTitleView
    }

    func refreshDetailView() {
        detailView.data = ticker

        pairListView.data = [self.curIndex, self.tickers]
    }

    func refreshView(_ hiddenKLine: Bool = true) {
        refreshDetailView()
        fetchKlineData(hiddenKLine)

        coordinator?.refreshChildViewController(pageContentView.childViewControllers as! [BaseViewController], pair: pair)
    }

    func fetchKlineData(_ hiddenKLine: Bool = true) {
        kLineView.isHidden = hiddenKLine

        resetKLinePosition = hiddenKLine
        AppConfiguration.shared.appCoordinator.requestKlineDetailData(pair: pair, gap: timeGap, vc: self, selector: #selector(refreshKLine))
    }

    func updateIndex() {
        let pairs = tickers.map({ Pair(base: $0.base, quote: $0.quote) })
        curIndex = pairs.index(of: pair)!
        ticker = tickers[self.curIndex]
        pair = pairs[self.curIndex]
    }

    @objc func refreshKLine() {
        if ticker.latest == "0" {
            endLoading()
            return
        }

        if let klineDatas = appData.detailData, let klineData = klineDatas[pair] {

            guard let response = klineData[timeGap] else {
                endLoading()
                return
            }

            endLoading()
            kLineView.isHidden = false

            var dataArray = [CBKLineModel]()
            for (_, data) in response.enumerated() {

                let base_assetid = pair.base
                let quote_assetid = pair.quote

                let is_base = data.base == base_assetid

                let base_info = appData.assetInfo[base_assetid]!
                let quote_info = appData.assetInfo[quote_assetid]!

                let base_precision = pow(10, base_info.precision.double)
                let quote_precision = pow(10, quote_info.precision.double)

                var open_price = (Double(data.openBase)! / base_precision) / (Double(data.openQuote)! / quote_precision)
                var close_price = (Double(data.closeBase)! / base_precision) / (Double(data.closeQuote)! / quote_precision)
                var high_price = (Double(data.highBase)! / base_precision) / (Double(data.highQuote)! / quote_precision)
                var low_price = (Double(data.lowBase)! / base_precision) / (Double(data.lowQuote)! / quote_precision)

                if !is_base {
                    open_price = (Double(data.openQuote)! / base_precision) / (Double(data.openBase)! / quote_precision)
                    close_price = (Double(data.closeQuote)! / base_precision) / (Double(data.closeBase)! / quote_precision)
                    high_price = (Double(data.lowQuote)! / base_precision) / (Double(data.lowBase)! / quote_precision)
                    low_price = (Double(data.highQuote)! / base_precision) / (Double(data.highBase)! / quote_precision)
                }

                if high_price > 1.3 * (open_price + close_price) * 0.5 {
                    high_price = max(open_price, close_price)
                }

                if low_price < 0.7 * (open_price + close_price) * 0.5 {
                    low_price = min(open_price, close_price)
                }
                let model = CBKLineModel(date: data.open, open: open_price, close: close_price, high: high_price, low: low_price, towardsVolume: (is_base ? Double(data.quoteVolume)! : Double(data.baseVolume)!) / quote_precision, volume: (is_base ? Double(data.baseVolume)! : Double(data.quoteVolume)!) / base_precision, precision: base_info.precision)

                let last_idx = dataArray.count - 1
                if last_idx >= 0 {
                    let gapCount = (model.date - dataArray[last_idx].date) / timeGap.rawValue
                    if gapCount > 1 {
                        for _ in 1 ..< Int(gapCount) {
                            let last_model = dataArray.last!
                            let gap_model = CBKLineModel(date: last_model.date + timeGap.rawValue, open: last_model.close, close: last_model.close, high: last_model.close, low: last_model.close, towardsVolume: 0, volume: 0, precision: last_model.precision)
                            dataArray.append(gap_model)
                        }
                    }
                }

                if let last_model = dataArray.last, (model.date - last_model.date) != 3600 {

                }

                dataArray.append(model)
            }

            if dataArray.count > 0 {
                var last_model = dataArray.last!

                let surplus_count = (Date().timeIntervalSince1970 - last_model.date) / timeGap.rawValue
                if surplus_count >= 1 {
                    for _ in 0 ..< Int(surplus_count) {
                        last_model = dataArray.last!
                        let gap_model = CBKLineModel(date: last_model.date + timeGap.rawValue, open: last_model.close, close: last_model.close, high: last_model.close, low: last_model.close, towardsVolume: 0, volume: 0, precision: last_model.precision)
                        dataArray.append(gap_model)
                    }
                }

                if let base_info = appData.assetInfo[self.ticker.base], timeGap == .oneDay {
                    last_model = dataArray.last!
                    detailView.highLabel.text = "High: " + last_model.high.formatCurrency(digitNum: base_info.precision)
                    detailView.lowLabel.text = "Low: " + last_model.low.formatCurrency(digitNum: base_info.precision)
                }
            }

            kLineView.drawKLineView(klineModels: dataArray, initialize: resetKLinePosition)
        }
    }

    override func configureObserveState() {

        appData.otherRequestRelyData.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if !CybexWebSocketService.shared.overload() {
                    self.performSelector(onMainThread: #selector(self.refreshTotalView), with: nil, waitUntilDone: false)
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    @objc func refreshTotalView() {
        if isVisible && !kLineSpecial {
            updateIndex()
            refreshView(false)
        }
    }
}

extension MarketViewController {
//    @objc func cellClicked(_ data: [String: Any]) {
//        if let index = data["index"] as? Int {
//            curIndex = index
//            let markets = buckets.map({ Pair(base: $0.base, quote: $0.quote) })
//            pair = markets[self.curIndex]
//            
//            startLoading()
//            refreshView()
//        }
//    }

    @objc func timeClicked(_ data: [String: Any]) {
        if let candlestick = data["candlestick"] as? Candlesticks {
            timeGap = candlestick

            startLoading()
            fetchKlineData()
        }
    }

    @objc func indicatorClicked(_ data: [String: Any]) {
        if let indicator = data["indicator"] as? Indicator {
            self.indicator = indicator
            kLineView.indicator = indicator

            startLoading()
            fetchKlineData()
        }
    }

    @objc func buy() {
        self.coordinator?.openTradeViewChontroller(true, pair: self.pair)
    }
    @objc func sell() {
        self.coordinator?.openTradeViewChontroller(false, pair: self.pair)
    }
}
