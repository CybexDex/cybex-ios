//
//  MarketViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import BigInt
import DNSPageView
import SwiftTheme
import Localize_Swift

class MarketViewController: BaseViewController {
  @IBOutlet weak var pageTitleView: DNSPageTitleView!
  @IBOutlet weak var pageContentView: DNSPageContentView!

  @IBOutlet weak var pageContentViewHeight: NSLayoutConstraint!
  @IBOutlet weak var scrollView: UIScrollView!
  

  @IBOutlet weak var pairListView: PairListHorizantalView!
  
  @IBOutlet weak var detailView: PairDetailView!
  @IBOutlet weak var kLineView: CBKLineView!
  
  var currentBaseIndex:Int = 0
  
  var timeGap:candlesticks = .one_day {
    didSet {
      kLineView.timeGap = timeGap
    }
  }
  
  var resetKLinePosition:Bool = true
  
  var indicator:indicator = .ma {
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
  
  var curIndex:Int = 0
  var coordinator: (MarketCoordinatorProtocol & MarketStateManagerProtocol)?
  
  lazy var pair:Pair = {
    return Pair(base: self.homeBucket.base, quote: self.homeBucket.quote)
  }()
  
  lazy var homeBucket:HomeBucket = {
    let market = self.buckets[self.curIndex]
    return market
  }()
  
  lazy var buckets:[HomeBucket] = {
    let markets = app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex])
    return markets
  }()

	override func viewDidLoad() {
    super.viewDidLoad()
//    self.localized_text = R.string.localizable.market.key.localizedContainer()
    let quote_name = homeBucket.quote_info.symbol.filterJade
    let base_name = homeBucket.base_info.symbol.filterJade
    
      self.title = quote_name + "/" + base_name
    self.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
    automaticallyAdjustsScrollViewInsets = false

    configLeftNavButton(nil)
    setupPageView()

    startLoading()
    refreshDetailView()
    fetchKlineData()
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
    let titles = Localize.currentLanguage() == "en" ? ["Order Book", "Trade History"] : ["买卖单", "交易历史"]
    
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
    pageContentView.collectionView.panGestureRecognizer.require(toFail: UIApplication.shared.coordinator().curDisplayingCoordinator().rootVC.interactivePopGestureRecognizer!)
    
    // 让titleView和contentView进行联系起来
    pageTitleView.delegate = pageContentView
    pageContentView.delegate = pageTitleView
  }
  
  func refreshDetailView() {
    detailView.data = homeBucket
    
    pairListView.data = [self.curIndex, self.buckets]
  }
  
  func refreshView(_ hiddenKLine:Bool = true) {
    self.refreshDetailView()
    fetchKlineData(hiddenKLine)


    self.coordinator?.refreshChildViewController(pageContentView.childViewControllers as! [BaseViewController], pair: pair)
  }
  
  func fetchKlineData(_ hiddenKLine:Bool = true) {
    self.kLineView.isHidden = hiddenKLine

    resetKLinePosition = hiddenKLine
    UIApplication.shared.coordinator().requestKlineDetailData(pair: pair, gap: timeGap, vc: self, selector: #selector(refreshKLine))
  }
  
  func updateIndex() {
    let markets = app_data.filterQuoteAsset(AssetConfiguration.market_base_assets[currentBaseIndex]).map( { Pair(base: $0.base, quote: $0.quote) })
    self.curIndex = markets.index(of: pair)!
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
      self.kLineView.isHidden = false

      var dataArray = [CBKLineModel]()
      for (_, data) in response.enumerated() {
        let base_assetid = data.base
        let base_info = app_data.assetInfo[base_assetid]!
        let base_precision = pow(10, base_info.precision.toDouble)
        let quote_assetid = data.quote
        let quote_info = app_data.assetInfo[quote_assetid]!
        let quote_precision = pow(10, quote_info.precision.toDouble)

        let open_price = (Double(data.open_base)! / base_precision)  / (Double(data.open_quote)! / quote_precision)
        let close_price = (Double(data.close_base)! / base_precision)  / (Double(data.close_quote)! / quote_precision)
        let high_price = (Double(data.high_base)! / base_precision)  / (Double(data.high_quote)! / quote_precision)
        let low_price = (Double(data.low_base)! / base_precision)  / (Double(data.low_quote)! / quote_precision)

        let model = CBKLineModel(date: data.open, open: open_price, close: close_price, high: high_price, low: low_price, volume: Double(data.base_volume)! / base_precision)
        
        
        let last_idx = dataArray.count - 1
        if last_idx >= 0 {

          let gapCount = (model.date - dataArray[last_idx].date) / timeGap.rawValue
          if gapCount > 1 {
            for _ in 1..<Int(gapCount) {
              let last_model = dataArray.last!
              let gap_model = CBKLineModel(date: last_model.date + timeGap.rawValue, open: last_model.close, close: last_model.close, high: last_model.close, low: last_model.close, volume: 0)
              dataArray.append(gap_model)
            }
          }
        }
        

        if let last_model = dataArray.last, (model.date - last_model.date) != 3600 {
          print(model.date - last_model.date)
          print("\r\n")
        }
        
        dataArray.append(model)
        
      }
      
      if dataArray.count > 0 {
        var last_model = dataArray.last!

        let surplus_count = (Date().timeIntervalSince1970 - last_model.date) / timeGap.rawValue
        if surplus_count >= 1 {
          for _ in 0..<Int(surplus_count) {
            last_model = dataArray.last!
            let gap_model = CBKLineModel(date: last_model.date + timeGap.rawValue, open: last_model.close, close: last_model.close, high: last_model.close, low: last_model.close, volume: 0)
            dataArray.append(gap_model)
          }
        }
      }
      self.kLineView.drawKLineView(klineModels: dataArray, initialize: resetKLinePosition)
    }
  }
  
  func commonObserveState() {
    coordinator?.subscribe(errorSubscriber) { sub in
        return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
            return false
        })
    }
  
    coordinator?.subscribe(loadingSubscriber) { sub in
        return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
            return false
        })
    }
  }
  
  override func configureObserveState() {
    commonObserveState()
    
    app_data.data.asObservable().distinctUntilChanged()
      .filter({$0.count == AssetConfiguration.shared.asset_ids.count}).skip(1)
      .subscribe(onNext: {[weak self] (s) in
        guard let `self` = self else { return }
        self.updateIndex()
        self.refreshView(false)
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
  }
  
  deinit {
    print("dealloc")
  }
}

extension MarketViewController {
  @objc func cellClicked(_ data:[String: Any]) {
    if let index = data["index"] as? Int {
      self.curIndex = index
      let markets = buckets.map( { Pair(base: $0.base, quote: $0.quote) })
      pair = markets[self.curIndex]
      
      startLoading()
      refreshView()
    }
  }
  
  @objc func timeClicked(_ data:[String: Any]) {
    if let candlestick = data["candlestick"] as? candlesticks {
      self.timeGap = candlestick
      
      startLoading()
      fetchKlineData()
    }
  }
  
  @objc func indicatorClicked(_ data:[String: Any]) {
    if let indicator = data["indicator"] as? indicator {
      self.indicator = indicator
      self.kLineView.indicator = indicator
      
      startLoading()
      fetchKlineData()
    }
  }
}

