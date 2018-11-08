//
//  HomeViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import RxSwift
import SwiftyJSON
import TinyConstraints
import Repeat

enum ViewType: Int {
    case homeContent    = 1
    case businessTitle
    case comprehensive
}

class HomeViewController: BaseViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    var timer: Timer?
    
    var coordinator: (HomeCoordinatorProtocol & HomeStateManagerProtocol)?
    
    var pair: Pair? {
        didSet {
            guard let pair = pair, let index = AssetConfiguration.marketBaseAssets.index(of: pair.base) else { return }
            
            if let selectedIndex = appData.filterQuoteAssetTicker(pair.base).index(where: { (ticker) -> Bool in
                return ticker.quote == pair.quote
            }) {
                self.businessTitleView?.selectedIndex = selectedIndex
                self.businessTitleView?.leftView.changeToHighStatus(1 + index, save: true)
            }
        }
    }
    
    var contentView: HomeContentView?
    var businessTitleView: BusinessTitleView?
    
    var base: String {
        if self.vcType == 1 {
            if let titleView = self.contentView {
                return AssetConfiguration.marketBaseAssets[titleView.currentBaseIndex]
            }
            return ""
        } else {
            if let titleView = self.businessTitleView {
                return AssetConfiguration.marketBaseAssets[titleView.currentBaseIndex]
            }
            return ""
        }
    }
    var vcType: Int = 1 {
        didSet {
            switchContainerView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        self.localizedText = R.string.localizable.navWatchlist.key.localizedContainer()
        switchContainerView()
    }
    
    func switchContainerView() {
        contentView?.removeFromSuperview()
        businessTitleView?.removeFromSuperview()
        if self.vcType == ViewType.homeContent.rawValue ||
            self.vcType == ViewType.comprehensive.rawValue {
            contentView = HomeContentView()
            contentView?.viewType = ViewType.init(rawValue: self.vcType) ?? ViewType.homeContent
            self.view.addSubview(contentView!)
            contentView?.edgesToDevice(vc: self,
                                       insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                       priority: .required,
                                       isActive: true,
                                       usingSafeArea: true)
        } else {
            businessTitleView = BusinessTitleView(frame: self.view.bounds)
            self.view.addSubview(businessTitleView!)
            businessTitleView?.edges(to: self.view,
                                     insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentView?.tableView.reloadData()
    }
    
    override func configureObserveState() {
        appData.tickerData.asObservable().filter({[weak self] (result) -> Bool in
            guard let `self` = self else { return false}
            if self.vcType == ViewType.comprehensive.rawValue {
                if result.count == AssetConfiguration.shared.assetIds.count {
                    return true
                }
            }
            else {
                let tickers = result.filter { (ticker) -> Bool in
                    return ticker.base == self.base
                }
                if tickers.count == AssetConfiguration.shared.assetIds.filter({ $0.base == self.base}).count,
                    tickers.count != 0 {
                    return true
                }
            }
            return false
        }).take(1)
            .subscribe(onNext: {[weak self] (data) in
                guard let `self` = self else { return }
                self.updateUI()
                self.timer = Timer.scheduledTimer(timeInterval: 3,
                                                  target: self,
                                                  selector: #selector(self.updateUI),
                                                  userInfo: nil,
                                                  repeats: true)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc func updateUI() {
        self.performSelector(onMainThread: #selector(self.refreshTableView),
                             with: nil,
                             waitUntilDone: false)// non block tracking mode
    }
    
    @objc func refreshTableView() {
        if self.isVisible {
            self.endLoading()
            let data = appData.tickerData.value
            if self.vcType == ViewType.homeContent.rawValue || self.vcType == ViewType.comprehensive.rawValue {
                self.contentView?.data = data.filter({$0.baseVolume != "0"})
                self.contentView?.viewType = ViewType(rawValue: self.vcType) ?? .homeContent
            } else {
                self.businessTitleView?.data = data.filter({$0.baseVolume != "0"})
            }
        }
    }
}

extension HomeViewController {
    @objc func cellClicked(_ data: [String: Any]) {
        if vcType == ViewType.homeContent.rawValue {//首页
            if let selectedPair = data["pair"] as? Pair {
                let tickers = appData.tickerData.value.filter({$0.base == AssetConfiguration.marketBaseAssets[self.contentView!.currentBaseIndex]})
                for index in 0..<tickers.count {
                    let item = tickers[index]
                    if item.base == selectedPair.base && item.quote == selectedPair.quote {
                        self.coordinator?.openMarket(index: index, currentBaseIndex: self.contentView!.currentBaseIndex)
                        return
                    }
                }
            }
        }
        else if vcType == ViewType.comprehensive.rawValue {
            if let index = data["index"] as? Int,
                appData.tickerData.value.count == AssetConfiguration.shared.assetIds.count {
                let datas = appData.filterPopAssetsCurrency()
                if datas.count > index {
                    let buckets = appData.filterPopAssetsCurrency()[index]
                    
                    if let baseIndex = AssetConfiguration.marketBaseAssets.firstIndex(of: buckets.base) {
                        let markets = appData.filterQuoteAssetTicker(buckets.base)
                        if let curIndex = markets.firstIndex(of: buckets) {
                            self.coordinator?.openMarket(index: curIndex, currentBaseIndex: baseIndex)
                        }
                    }
                }
            }
        }
        else {
            if let value = data["info"] as? Pair {
                if let superVC = self.parent as? TradeViewController {
                    superVC.pair = value
                }
            }
        }
    }
}
