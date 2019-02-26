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
import Reachability

extension NSNotification.Name {
    static let SpecialPairDidClicked = Notification.Name("SpecialPairDidClicked")
    static let SpecialPairDidCanceled = Notification.Name("SpecialPairDidCanceled")

}

class MarketViewController: BaseViewController {
    @IBOutlet var pageContentViewHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var detailView: PairDetailView!
    @IBOutlet var kLineView: CBKLineView!
    @IBOutlet var marketDetailView: PairDetailView!
    @IBOutlet weak var rechargeView: PairRechargeView!
    @IBOutlet weak var rechargeHeight: NSLayoutConstraint!

    var rechargeShowType = PairRechargeView.ShowType.show.rawValue

    var kLineSpecial = false
    var canExchange = false
    var daySelectedIndex = 2
    var indicatorSelectedIndex = 0
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
                CBConfiguration.sharedConfiguration.main.indicatorType = .MA([7, 25])
            case .ema:
                CBConfiguration.sharedConfiguration.main.indicatorType = .EMA([7, 25])
            case .macd:
                CBConfiguration.sharedConfiguration.main.indicatorType = .MACD
            case .boll:
                CBConfiguration.sharedConfiguration.main.indicatorType = .BOLL(20)
            case .none:
                break
            }
        }
    }

    var coordinator: (MarketCoordinatorProtocol & MarketStateManagerProtocol)?

    var pair: Pair?

    var ticker: Ticker? {
        return MarketHelper.getTickerByPair(pair)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        monitorNetwork()
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

        if let quoteInfo = appData.assetInfo[pair!.quote], let baseInfo = appData.assetInfo[pair!.base] {
            quoteName = quoteInfo.symbol.filterJade
            baseName = baseInfo.symbol.filterJade
        }

        title = quoteName + "/" + baseName
        view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
        automaticallyAdjustsScrollViewInsets = false
        marketDetailView.baseName = baseName
        marketDetailView.quoteName = quoteName

        startLoading()
        refreshDetailView()
        fetchKlineData()
    }

    func monitorNetwork() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }

            switch reachability.connection {
            case .wifi, .cellular:
                self.fetchNotReadMessageIdData()
            case .none:

                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotReadMessageIdData()
    }
    
    func fetchNotReadMessageIdData() {
        if let quoteInfo = appData.assetInfo[pair!.quote], let baseInfo = appData.assetInfo[pair!.base] {
            let quoteName = quoteInfo.symbol.filterOnlyJade
            let baseName = baseInfo.symbol.filterOnlyJade
            let channel = quoteName + "/" + baseName
            self.coordinator?.fetchLastMessageId(channel, callback: { [weak self](lastId) in
                guard let self = self else {
                    return
                }
                self.kLineView.messageCount = lastId
            })
        }
    }
    
    func setupNotificatin() {
        NotificationCenter.default.addObserver(forName: .SpecialPairDidClicked,
                                               object: nil,
                                               queue: nil) {[weak self] (notifi) in
                                                guard let self = self else { return }
                                                self.kLineSpecial = true
                                                self.detailView.data = notifi.userInfo?["klineModel"]
        }

        NotificationCenter.default.addObserver(forName: .SpecialPairDidCanceled, object: nil, queue: nil) {[weak self] (_) in
            guard let self = self else { return }
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

    func refreshDetailView() {
        detailView.data = ticker
    }

    func refreshView(_ hiddenKLine: Bool = true, isRefreshSelf: Bool = true) {
        if isRefreshSelf {
            refreshDetailView()
            fetchKlineData(hiddenKLine)
        }
    }

    func fetchKlineData(_ hiddenKLine: Bool = true) {
        kLineView.isHidden = hiddenKLine

        resetKLinePosition = hiddenKLine

        self.coordinator?.requestKlineDetailData(pair: pair!, gap: timeGap)
    }

    func refreshKLine() {
        if let ticker = ticker, ticker.latest == "0" {
            endLoading()
            return
        }

        if let klineDatas = self.coordinator?.state.detailData.value, let klineData = klineDatas[pair!] {

            guard let response = klineData[timeGap] else {
                endLoading()
                return
            }

            endLoading()
            kLineView.isHidden = false
            let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(self.pair!)

            DispatchQueue.global().async {
                var dataArray = [CBKLineModel]()
                for data in response {

                    let baseAssetId = self.pair!.base
                    let quoteAssetId = self.pair!.quote

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

                    //                if highPrice > 1.3 * (openPrice + closePrice) * 0.5 {
                    //                    highPrice = max(openPrice, closePrice)
                    //                }
                    //
                    //                if lowPrice < 0.7 * (openPrice + closePrice) * 0.5 {
                    //                    lowPrice = min(openPrice, closePrice)
                    //                }
                    
                    
                    let model = CBKLineModel(date: data.open,
                                             open: openPrice,
                                             close: closePrice,
                                             high: highPrice,
                                             low: lowPrice,
                                             towardsVolume: (isBase ? Double(data.quoteVolume)! : Double(data.baseVolume)!) / quotePrecision,
                                             volume: (isBase ? Double(data.baseVolume)! : Double(data.quoteVolume)!) / basePrecision,
                                             precision: tradePrecision.price)

                    let lastIdx = dataArray.count - 1
                    if lastIdx >= 0 {
                        let gapCount = (model.date - dataArray[lastIdx].date) / self.timeGap.rawValue.double
                        if gapCount > 1 {
                            for _ in 1 ..< Int(gapCount) {
                                let lastModel = dataArray.last!
                                let gapModel = CBKLineModel(date: lastModel.date + self.timeGap.rawValue.double,
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

                    let surplusCount = (Date().timeIntervalSince1970 - lastModel.date) / self.timeGap.rawValue.double
                    if surplusCount >= 1 {
                        for _ in 0 ..< Int(surplusCount) {
                            lastModel = dataArray.last!
                            let gapModel = CBKLineModel(date: lastModel.date + self.timeGap.rawValue.double,
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
                    if let ticker = self.ticker, let _ = appData.assetInfo[ticker.base], self.timeGap == .oneDay {
                        lastModel = dataArray.last!
                        DispatchQueue.main.async {
                            self.detailView.highLabel.text = "High: " + lastModel.high.decimal.formatCurrency(digitNum: tradePrecision.price)
                            self.detailView.lowLabel.text = "Low: " + lastModel.low.decimal.formatCurrency(digitNum: tradePrecision.price)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.kLineView.drawKLineView(klineModels: dataArray, initialize: self.resetKLinePosition)
                }
            }

        }
    }

    override func configureObserveState() {
        appData.otherRequestRelyData.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if !CybexWebSocketService.shared.overload() {
                    self.performSelector(onMainThread: #selector(self.refreshTotalView), with: nil, waitUntilDone: false)
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        coordinator?.state.detailData.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let self = self else { return }

            self.refreshKLine()
        }).disposed(by: disposeBag)

    }

    @objc func refreshTotalView() {
        if isVisible {
            refreshView(false, isRefreshSelf: !kLineSpecial)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueinfo = R.segue.marketViewController.marketDetailPageTabViewController(segue: segue) {
            segueinfo.destination.pair = self.pair
            if let rootNav = self.navigationController as? BaseNavigationController {
                segueinfo.destination.rootNav = rootNav
            }
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
        self.coordinator?.openTradeViewChontroller(true, pair: self.pair!)
    }
    @objc func sell() {
        self.coordinator?.openTradeViewChontroller(false, pair: self.pair!)
    }
    
    @objc func dropDownBoxViewDidClicked(_ data: [String: Any]) {
        guard let dropView = data["self"] as? DropDownBoxView else {
            return
        }
        self.selectedDropKindView = dropView
        self.coordinator?.setDropBoxViewController()
    }
    
    @objc func openMessageVC(_ data: [String: Any]) {
        self.coordinator?.openChatVC(self.pair!)
    }
}


extension MarketViewController {
    override func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        selectedDropKindView?.resetState()
        return true
    }
}

extension MarketViewController: RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String, index: Int) {
        selectedDropKindView?.nameLabel.text = info
        selectedDropKindView?.resetState()
        
        if selectedDropKindView?.dropKind == .time {
            daySelectedIndex = index
            self.timeClicked(["candlestick": Candlesticks.all[sender.selectedIndex]])
        }else if selectedDropKindView?.dropKind == .kind {
            indicatorSelectedIndex = index
            self.indicatorClicked(["indicator": Indicator.all[sender.selectedIndex]])
        }
        sender.dismiss(animated: false, completion: nil)
    }
}
