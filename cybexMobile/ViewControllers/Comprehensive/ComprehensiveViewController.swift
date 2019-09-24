//
//  ComprehensiveViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift
import SwifterSwift
import SwiftyUserDefaults


class ComprehensiveViewController: BaseViewController {

    var coordinator: (ComprehensiveCoordinatorProtocol & ComprehensiveStateManagerProtocol)?

    @IBOutlet weak var contentView: ComprehensiveView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()
        setupTableView()
    }

    func setupNavi() {
        self.navigationController?.navigationBar.isHidden = true
    }

    func setupTableView() {

        self.addPullToRefresh(contentView.scrollView) {[weak self] (completion) in
            self?.coordinator?.fetchData()
//            completion?()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavi()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.isHidden = false
    }

    override func refreshViewController() {
    }

    func setupUI() {
        self.coordinator?.setupChildrenVC(self)
    }

    func setupData() {
        startLoading()
        self.coordinator?.fetchData()
    }

    func setupEvent() {

    }

    override func configureObserveState() {
        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let self = self else { return }

            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))

            case .loading(let reason):
                if reason == .initialRefresh {
                }
            case .refresh(let type):
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))

            case .loadMore:
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))

            case .noMore:
                break
            case .noData:
                break
            case .normal:
                break
            case .error(let error, _):
                self.showToastBox(false, message: error.localizedDescription)
            }
        }).disposed(by: disposeBag)

        appData.tickerData.asObservable().distinctUntilChanged().filter { (tickers) -> Bool in
            return tickers.count >= MarketConfiguration.shared.marketPairs.value.count
            }.subscribe(onNext: { [weak self](tickers) in
                guard let self = self else { return }
                if let hotPairs = self.coordinator?.state.hotPairs.value, self.isVisible {
                    var tickerModel = [Ticker]()
                    for pair in hotPairs {
                        if let hotPair = tickers.filter({ (ticker) -> Bool in
                            return ticker.base == pair.base && ticker.quote == pair.quote
                        }).first {
                            tickerModel.append(hotPair)
                        }
                    }
                    // MARK: 交易对
                    self.contentView.hotAssetsView.isHidden = false
                    self.contentView.hotAssetsView.adapterModelToHotAssetsView(tickerModel)
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.coordinator?.state.announces.asObservable().subscribe(onNext: { [weak self](announces) in
            guard let self = self, let announces = announces else { return }
            let titles = announces.map({ (announce) -> String in
                return announce.title
            })
            self.contentView.announceView.scrollLableView.data = titles

            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.coordinator?.state.banners.asObservable().subscribe(onNext: { [weak self](banners) in
            guard let self = self, let bannerInfos = banners else { return }
            let images = bannerInfos.map({ (banner) -> String in
                return banner.image
            })
            self.contentView.bannerView.adapterModelToETOHomeBannerView(images)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.coordinator?.state.middleItems.asObservable().subscribe(onNext: { [weak self](middleItems) in
            guard let self = self, let items = middleItems else { return }

            self.contentView.middleItemsView.adapterModelToComprehensiveItemsView(items)
            self.stopPullRefresh(self.contentView.scrollView)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil) { [weak self](_) in
            guard let self = self else { return }
            self.coordinator?.fetchData()
        }

        Observable.combineLatest(self.coordinator!.state.hotPairs.asObservable(),
                                 self.coordinator!.state.middleItems.asObservable(),
                                 self.coordinator!.state.banners.asObservable(),
                                 self.coordinator!.state.announces.asObservable()).subscribe(onNext: { [weak self](hotPairs, middleItems, banners, announces) in
                                    guard self != nil else { return }
                                    if let _ = hotPairs, let _ = middleItems, let _ = banners, let _ = announces {
//                                        self.endLoading()
                                    }

                                    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        NotificationCenter.default.addObserver(forName: .NetWorkChanged, object: nil, queue: nil) { [weak self](_) in
            guard let self = self else { return }
            delay(milliseconds: 1000) {
                self.coordinator?.fetchData()
            }
        }
    }
}

extension ComprehensiveViewController {
    @objc func comprehensiveItemViewDidClicked(_ data: [String: Any]) {
        guard let middleItems = self.coordinator?.state.middleItems.value,
            let index = data["index"] as? Int else { return }

        let midlleItem = middleItems[index]

        if midlleItem.needlogin, !UserManager.shared.logined {
            appCoodinator.showLogin()
            return
        }

        if midlleItem.needtalk == .gamecenter {
            self.coordinator?.openGame(midlleItem.link)

            return
        }
        
        openUrl(midlleItem.link, needLogin: midlleItem.needlogin)
    }
    
    @objc func ETOHomeBannerViewDidClicked(_ data: [String: Any]) {
        guard let banners = self.coordinator?.state.banners.value, let index = data["data"] as? Int  else { return }
        let banner = banners[index]
        openUrl(banner.link)
    }
    
    @objc func announceScrollViewDidClicked(_ data: [String: Any]) {
        guard let announces = self.coordinator?.state.announces.value, let index = data["index"] as? Int, index >= 0, index < announces.count else {
            return
        }
        let announce = announces[index]
        openUrl(announce.url)
    }
    @objc func hotAssetViewDidClicked(_ data: [String: Any]) {
        if let data = data["data"] as? Ticker {
            self.coordinator?.openMarketList(Pair(base: data.base, quote: data.quote))
        }
    }

    func openUrl(_ url: String, needLogin: Bool = true) {
        if url.contains("cybexapp://") {
            if needLogin, !UserManager.shared.logined {
                appCoodinator.showLogin()
                return
            }
            openPage(url)
        } else {
            if url.contains("http://") || url.contains("https://") {
                self.coordinator?.openWebVCUrl(url)
            }
        }
    }
}
