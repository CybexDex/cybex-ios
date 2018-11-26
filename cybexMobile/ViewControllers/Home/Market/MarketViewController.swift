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

    var rechargeShowType = PairRechargeView.ShowType.show.rawValue
    var currentBaseIndex: Int = 0
    var kLineSpecial = false
    var canExchange = false
    var selectedDropKindView: DropDownBoxView?
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
        if self.curIndex < self.tickers.count {
            let market = self.tickers[self.curIndex]
            return market
        }
        return Ticker()
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
        if self.rechargeShowType == PairRechargeView.ShowType.hidden.rawValue {
            rechargeHeight.constant = 0
        } else {
            rechargeHeight.constant = 56
        }
        setupNotificatin()
        setupEvent()
        var quoteName = ""
        var baseName = ""

        if let quoteInfo = appData.assetInfo[ticker.quote], let baseInfo = appData.assetInfo[ticker.base] {
            quoteName = quoteInfo.symbol.filterJade
            baseName = baseInfo.symbol.filterJade
        }

        title = quoteName + "/" + baseName
        view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        automaticallyAdjustsScrollViewInsets = false
        marketDetailView.baseName = baseName
        marketDetailView.quoteName = quoteName

        setupPageView()

        startLoading()
        refreshDetailView()
        fetchKlineData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotReadMessageIdData()
    }
    
    func fetchNotReadMessageIdData(){
        var lastMessageId = 0
        if var dic = UserDefaults.standard.value(forKey: "lastReadIds") as? [Pair: String], let cacheMessageId = dic[pair] {
            lastMessageId = Int(cacheMessageId) ?? 0
        }
        self.coordinator?.fetchLastMessageId(self.title!, callback: { [weak self](lastId) in
            guard let `self` = self else {
                return
            }
            self.kLineView.messageCount = lastId
        })
    }
    
    func setupNotificatin() {
        NotificationCenter.default.addObserver(forName: .SpecialPairDidClicked,
                                               object: nil,
                                               queue: nil) {[weak self] (notifi) in
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

    func refreshView(_ hiddenKLine: Bool = true, isRefreshSelf: Bool = true) {
        if isRefreshSelf {
            refreshDetailView()
            fetchKlineData(hiddenKLine)
        }
        if let pageChildVCs = pageContentView.childViewControllers as? [BaseViewController] {
            coordinator?.refreshChildViewController(pageChildVCs, pair: pair)
        }
    }

    func fetchKlineData(_ hiddenKLine: Bool = true) {
        kLineView.isHidden = hiddenKLine

        resetKLinePosition = hiddenKLine
        AppConfiguration.shared.appCoordinator.requestKlineDetailData(pair: pair, gap: timeGap, vc: self, selector: #selector(refreshKLine))
    }

    func updateIndex() {
        let pairs = tickers.map({ Pair(base: $0.base, quote: $0.quote) })
        if let index = pairs.index(of: pair), index < tickers.count, index < pairs.count {
            curIndex = index
            ticker = tickers[self.curIndex]
            pair = pairs[self.curIndex]
        }
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

                let baseAssetId = pair.base
                let quoteAssetId = pair.quote

                let isBase = data.base == baseAssetId

                let baseInfo = appData.assetInfo[baseAssetId]!
                let quoteInfo = appData.assetInfo[quoteAssetId]!

                let basePrecision = pow(10, baseInfo.precision.double)
                let quotePrecision = pow(10, quoteInfo.precision.double)

                var openPrice = (Double(data.openBase)! / basePrecision) / (Double(data.openQuote)! / quotePrecision)
                var closePrice = (Double(data.closeBase)! / basePrecision) / (Double(data.closeQuote)! / quotePrecision)
                var highPrice = (Double(data.highBase)! / basePrecision) / (Double(data.highQuote)! / quotePrecision)
                var lowPrice = (Double(data.lowBase)! / basePrecision) / (Double(data.lowQuote)! / quotePrecision)

                if !isBase {
                    openPrice = (Double(data.openQuote)! / basePrecision) / (Double(data.openBase)! / quotePrecision)
                    closePrice = (Double(data.closeQuote)! / basePrecision) / (Double(data.closeBase)! / quotePrecision)
                    highPrice = (Double(data.lowQuote)! / basePrecision) / (Double(data.lowBase)! / quotePrecision)
                    lowPrice = (Double(data.highQuote)! / basePrecision) / (Double(data.highBase)! / quotePrecision)
                }

                if highPrice > 1.3 * (openPrice + closePrice) * 0.5 {
                    highPrice = max(openPrice, closePrice)
                }

                if lowPrice < 0.7 * (openPrice + closePrice) * 0.5 {
                    lowPrice = min(openPrice, closePrice)
                }
                let model = CBKLineModel(date: data.open,
                                         open: openPrice,
                                         close: closePrice,
                                         high: highPrice,
                                         low: lowPrice,
                                         towardsVolume: (isBase ? Double(data.quoteVolume)! : Double(data.baseVolume)!) / quotePrecision,
                                         volume: (isBase ? Double(data.baseVolume)! : Double(data.quoteVolume)!) / basePrecision,
                                         precision: baseInfo.precision)

                let lastIdx = dataArray.count - 1
                if lastIdx >= 0 {
                    let gapCount = (model.date - dataArray[lastIdx].date) / timeGap.rawValue
                    if gapCount > 1 {
                        for _ in 1 ..< Int(gapCount) {
                            let lastModel = dataArray.last!
                            let gapModel = CBKLineModel(date: lastModel.date + timeGap.rawValue,
                                                        open: lastModel.close,
                                                        close: lastModel.close,
                                                        high: lastModel.close,
                                                        low: lastModel.close,
                                                        towardsVolume: 0,
                                                        volume: 0,
                                                        precision: lastModel.precision)
                            dataArray.append(gapModel)
                        }
                    }
                }
                if let lastModel = dataArray.last, (model.date - lastModel.date) != 3600 {

                }
                dataArray.append(model)
            }

            if dataArray.count > 0 {
                var lastModel = dataArray.last!

                let surplusCount = (Date().timeIntervalSince1970 - lastModel.date) / timeGap.rawValue
                if surplusCount >= 1 {
                    for _ in 0 ..< Int(surplusCount) {
                        lastModel = dataArray.last!
                        let gapModel = CBKLineModel(date: lastModel.date + timeGap.rawValue,
                                                    open: lastModel.close,
                                                    close: lastModel.close,
                                                    high: lastModel.close,
                                                    low: lastModel.close,
                                                    towardsVolume: 0,
                                                    volume: 0,
                                                    precision: lastModel.precision)
                        dataArray.append(gapModel)
                    }
                }
                if let baseInfo = appData.assetInfo[self.ticker.base], timeGap == .oneDay {
                    lastModel = dataArray.last!
                    detailView.highLabel.text = "High: " + lastModel.high.formatCurrency(digitNum: baseInfo.precision)
                    detailView.lowLabel.text = "Low: " + lastModel.low.formatCurrency(digitNum: baseInfo.precision)
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
        if isVisible {
            updateIndex()
            refreshView(false, isRefreshSelf: !kLineSpecial)
        }
    }
}

extension MarketViewController {
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
    
    @objc func dropDownBoxViewDidClicked(_ data: [String: Any]) {
        guard let dropView = data["self"] as? DropDownBoxView else {
            return
        }
        self.selectedDropKindView = dropView
        self.coordinator?.setDropBoxViewController()
    }
    
    @objc func openMessageVC(_ data: [String: Any]) {
        self.coordinator?.openChatVC(self.pair)
    }
}


extension MarketViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        selectedDropKindView?.resetState()
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

extension MarketViewController: RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String) {
        selectedDropKindView?.nameLabel.text = info
        selectedDropKindView?.resetState()
        
        if selectedDropKindView?.dropKind == .time {
            self.timeClicked(["candlestick": Candlesticks.all[sender.selectedIndex]])
        }else if selectedDropKindView?.dropKind == .kind {
            self.indicatorClicked(["indicator": Indicator.all[sender.selectedIndex]])
        }
        sender.dismiss(animated: false, completion: nil)
    }
}
