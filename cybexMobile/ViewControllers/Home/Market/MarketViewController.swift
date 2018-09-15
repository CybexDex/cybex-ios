//
//  MarketViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import DNSPageView
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
    
    var timeGap: candlesticks = .one_day {
        didSet {
            kLineView.timeGap = timeGap
            CBConfiguration.sharedConfiguration.main.timeLineType = CBTimeLineType(rawValue: Int(timeGap.rawValue))!
        }
    }
    
    var resetKLinePosition: Bool = true
    
    var indicator: indicator = .ma {
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
        Pair(base: self.homeBucket.base, quote: self.homeBucket.quote)
    }()
    
    lazy var homeBucket: HomeBucket = {
        let market = self.buckets[self.curIndex]
        return market
    }()
    
    lazy var buckets: [HomeBucket] = {
        let markets = app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex])
        return markets
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rechargeView.showType = self.rechargeShowType
        if self.rechargeShowType == PairRechargeView.show_type.hidden.rawValue{
            rechargeHeight.constant = 0
        }else{
            rechargeHeight.constant = 56
        }
        setupNotificatin()
        setupEvent()
        
        let quote_name = homeBucket.quote_info.symbol.filterJade
        let base_name = homeBucket.base_info.symbol.filterJade
        
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
        
        NotificationCenter.default.addObserver(forName: .SpecialPairDidCanceled, object: nil, queue: nil) {[weak self] (notifi) in
            guard let `self` = self else { return }
            self.kLineSpecial = false
            self.refreshDetailView()
        }
    }
    
    func setupEvent(){
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
        style.titleFontSize = 14
        
        // 设置标题内容
        let titles = [R.string.localizable.mark_order_book.key.localized(),R.string.localizable.mark_trade_history.key.localized()]
        
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
        detailView.data = homeBucket
        
        pairListView.data = [self.curIndex, self.buckets]
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
        let markets = app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex]).map({ Pair(base: $0.base, quote: $0.quote) })
        curIndex = markets.index(of: pair)!
        homeBucket = buckets[self.curIndex]
        pair = markets[self.curIndex]
    }
    
    @objc func refreshKLine() {
        if homeBucket.bucket.count == 0 {
            endLoading()
            return
        }
        
        if let klineDatas = app_data.detailData, let klineData = klineDatas[pair] {
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
                
                let base_info = app_data.assetInfo[base_assetid]!
                let quote_info = app_data.assetInfo[quote_assetid]!
                
                let base_precision = pow(10, base_info.precision.double)
                let quote_precision = pow(10, quote_info.precision.double)
                
                var open_price = (Double(data.open_base)! / base_precision) / (Double(data.open_quote)! / quote_precision)
                var close_price = (Double(data.close_base)! / base_precision) / (Double(data.close_quote)! / quote_precision)
                var high_price = (Double(data.high_base)! / base_precision) / (Double(data.high_quote)! / quote_precision)
                var low_price = (Double(data.low_base)! / base_precision) / (Double(data.low_quote)! / quote_precision)
                
                if !is_base {
                    open_price = (Double(data.open_quote)! / base_precision) / (Double(data.open_base)! / quote_precision)
                    close_price = (Double(data.close_quote)! / base_precision) / (Double(data.close_base)! / quote_precision)
                    high_price = (Double(data.low_quote)! / base_precision) / (Double(data.low_base)! / quote_precision)
                    low_price = (Double(data.high_quote)! / base_precision) / (Double(data.high_base)! / quote_precision)
                }
                
                if high_price > 1.3 * (open_price + close_price) * 0.5 {
                    high_price = max(open_price, close_price)
                }
                
                if low_price < 0.7 * (open_price + close_price) * 0.5 {
                    low_price = min(open_price, close_price)
                }
                let model = CBKLineModel(date: data.open, open: open_price, close: close_price, high: high_price, low: low_price, towardsVolume: (is_base ? Double(data.quote_volume)! : Double(data.base_volume)!) / quote_precision , volume: (is_base ? Double(data.base_volume)! : Double(data.quote_volume)!) / base_precision, precision: base_info.precision)
                
                let last_idx = dataArray.count - 1
                if last_idx >= 0 {
                    let gapCount = (model.date - dataArray[last_idx].date) / timeGap.rawValue
                    if gapCount > 1 {
                        for _ in 1 ..< Int(gapCount) {
                            let last_model = dataArray.last!
                            let gap_model = CBKLineModel(date: last_model.date + timeGap.rawValue, open: last_model.close, close: last_model.close, high: last_model.close, low: last_model.close, towardsVolume:0, volume: 0, precision: last_model.precision)
                            dataArray.append(gap_model)
                        }
                    }
                }
                
                if let last_model = dataArray.last, (model.date - last_model.date) != 3600 {
                    //          print(model.date - last_model.date)
                    //          print("\r\n")
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
            }
            kLineView.drawKLineView(klineModels: dataArray, initialize: resetKLinePosition)
        }
    }
    
    override func configureObserveState() {
        
        app_data.otherRequestRelyData.asObservable()
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
    @objc func cellClicked(_ data: [String: Any]) {
        if let index = data["index"] as? Int {
            curIndex = index
            let markets = buckets.map({ Pair(base: $0.base, quote: $0.quote) })
            pair = markets[self.curIndex]
            
            startLoading()
            refreshView()
        }
    }
    
    @objc func timeClicked(_ data: [String: Any]) {
        if let candlestick = data["candlestick"] as? candlesticks {
            timeGap = candlestick
            
            startLoading()
            fetchKlineData()
        }
    }
    
    @objc func indicatorClicked(_ data: [String: Any]) {
        if let indicator = data["indicator"] as? indicator {
            self.indicator = indicator
            kLineView.indicator = indicator
            
            startLoading()
            fetchKlineData()
        }
    }
    
    @objc func buy(){
        self.coordinator?.openTradeViewChontroller(true,pair:self.pair)
    }
    @objc func sell(){
        self.coordinator?.openTradeViewChontroller(false,pair:self.pair)
    }
}
