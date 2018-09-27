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

class ComprehensiveViewController: BaseViewController {

	var coordinator: (ComprehensiveCoordinatorProtocol & ComprehensiveStateManagerProtocol)?
    
    @IBOutlet weak var contentView: ComprehensiveView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupUI()
        setupEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startLoading()
        self.coordinator?.fetchData()
    }
    
    
    override func refreshViewController() {
        
    }
    
    func setupUI() {
        self.navigationItem.titleView = UIImageView(image: R.image.img_etologo())
    }

    func setupData() {
        
    }
    
    func setupEvent() {
        
    }
    
    override func configureObserveState() {
        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let `self` = self else { return }
            
//            self.endLoading()
            
            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))
                
            case .loading(let reason):
                if reason == .initialRefresh {
                    self.startLoading()
                }
                
            case .refresh(let type):
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))
                
            case .loadMore(let page):
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))
                
            case .noMore:
//                self.stopInfiniteScrolling(self.tableView, haveNoMore: true)
                break
                
            case .noData:
//                self.view.showNoData(<#title#>, icon: <#imageName#>)
                break
                
            case .normal(let reason):
//                self.view.hiddenNoData()
//
//                if reason == PageLoadReason.manualLoadMore {
//                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
//                }
//                else if reason == PageLoadReason.manualRefresh {
//                    self.stopPullRefresh(self.tableView)
//                }
                break
                
            case .error(let error, let reason):
                self.showToastBox(false, message: error.localizedDescription)
                
//                if reason == PageLoadReason.manualLoadMore {
//                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
//                }
//                else if reason == PageLoadReason.manualRefresh {
//                    self.stopPullRefresh(self.tableView)
//                }
            }
        }).disposed(by: disposeBag)
        
        app_data.data.asObservable().filter { (bucket) -> Bool in
            return bucket.count == AssetConfiguration.shared.asset_ids.count
            }.subscribe(onNext: { [weak self](bucket) in
                guard let `self` = self else { return }
                if let hotPairs = self.coordinator?.state.hotPairs.value {
                    var bucketModel = [HomeBucket]()
                    for pair in hotPairs {
                        if let hotPair = bucket.filter({ (homeBucket) -> Bool in
                            return homeBucket.base == pair.base && homeBucket.quote == pair.quote
                        }).first {
                            bucketModel.append(hotPair)
                        }
                    }
                    // MARK: 交易对
                    self.contentView.hotAssetsView.isHidden = false
                    self.contentView.hotAssetsView.adapterModelToHotAssetsView(bucketModel)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.announces.asObservable().subscribe(onNext: { [weak self](announces) in
            guard let `self` = self, let announces = announces else { return }
            self.contentView.announceView.scrollLableView.data = announces.map({ (announce) -> String in
                return announce.title
            })
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.banners.asObservable().subscribe(onNext: { [weak self](banners) in
            guard let `self` = self, let bannerInfos = banners else { return }
            let images = bannerInfos.map({ (banner) -> String in
                return banner.image
            })
            self.contentView.bannerView.adapterModelToETOHomeBannerView(images)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.middleItems.asObservable().subscribe(onNext: { [weak self](middleItems) in
            guard let `self` = self, let items = middleItems else { return }
            self.contentView.moudlesView.adapterModelToComprehensiveItemsView(items)
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            self.coordinator?.fetchData()
        }
        
        Observable.combineLatest(self.coordinator!.state.hotPairs.asObservable(), self.coordinator!.state.middleItems.asObservable(), self.coordinator!.state.banners.asObservable(), self.coordinator!.state.announces.asObservable()).subscribe(onNext: { [weak self](hotPairs, middleItems, banners, announces) in
            guard let `self` = self else { return }
            if let _ = hotPairs, let _ = middleItems, let _ = banners, let _ = announces {
                self.endLoading()
            }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        NotificationCenter.default.addObserver(forName: NotificationName.NetWorkChanged, object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            self.coordinator?.fetchData()
        }
    }
}

extension ComprehensiveViewController {
    @objc func ComprehensiveItemViewDidClicked(_ data: [String: Any]) {
        guard let middleItems = self.coordinator?.state.middleItems.value,  let index = data["index"] as? Int else { return }
        let midlleItem = middleItems[index]
        openUrl(midlleItem.link)
    }
    
    @objc func ETOHomeBannerViewDidClicked(_ data: [String: Any]){
        guard let banners = self.coordinator?.state.banners.value, let index = data["data"] as? Int  else { return }
        let banner = banners[index]
        
        openUrl(banner.link)
    }
    
    @objc func AnnounceScrollViewDidClicked(_ data: [String: Any]) {
        guard let announces = self.coordinator?.state.announces.value, let index = data["index"] as? Int else {
            return
        }
        let announce = announces[index]
        openUrl(announce.url)
    }
    
    func openUrl(_ url: String) {
        if url.contains("https://") || url.contains("http://") {
            self.coordinator?.openWebVCUrl(url)
        }
        else {
            if !UserManager.shared.isLoginIn {
                app_coodinator.showLogin()
                return
            }
            openPage(url)
        }
    }
}

