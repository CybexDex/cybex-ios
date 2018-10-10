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

enum view_type : Int{
    case homeContent    = 1
    case businessTitle
    case Comprehensive
}
class HomeViewController: BaseViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    var timer:Timer?
    
    var coordinator: (HomeCoordinatorProtocol & HomeStateManagerProtocol)?
    
    var pair: Pair? {
        didSet{
            guard let pair = pair , let index = AssetConfiguration.market_base_assets.index(of: pair.base) else { return }
            
            if let selectedIndex = app_data.filterQuoteAsset(pair.base).index(where: { (bucket) -> Bool in
                return bucket.quote == pair.quote
            }) {
                self.businessTitleView?.selectedIndex = selectedIndex
                self.businessTitleView?.leftView.changeToHighStatus(1 + index, save:true)
            }
        }
    }
    
    var contentView : HomeContentView?
    var businessTitleView : BusinessTitleView?
    
    var base:String {
        if self.VC_TYPE == 1 {
            if let titleView = self.contentView {
                return AssetConfiguration.market_base_assets[titleView.currentBaseIndex]
            }
            return ""
        }
        else {
            if let titleView = self.businessTitleView {
                return AssetConfiguration.market_base_assets[titleView.currentBaseIndex]
            }
            return ""
        }
    }
    var VC_TYPE : Int = 1 {
        didSet {
            switchContainerView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
//        if VC_TYPE == view_type.homeContent.rawValue {
//            handlerUpdateVersion(nil)
//        }
        
    }
    
    func setupUI() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
        
        self.localized_text = R.string.localizable.navWatchlist.key.localizedContainer()
        switchContainerView()
    }
    
    func switchContainerView() {
        contentView?.removeFromSuperview()
        businessTitleView?.removeFromSuperview()
        if self.VC_TYPE == view_type.homeContent.rawValue || self.VC_TYPE == view_type.Comprehensive.rawValue{
            contentView = HomeContentView()
            contentView?.viewType = view_type.init(rawValue: self.VC_TYPE) ?? view_type.homeContent
            self.view.addSubview(contentView!)
            contentView?.edgesToDevice(vc:self, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), priority: .required, isActive: true, usingSafeArea: true)
            
        }else{
            businessTitleView = BusinessTitleView(frame: self.view.bounds)
            self.view.addSubview(businessTitleView!)
            businessTitleView?.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentView?.tableView.reloadData()
    }
    
    override func configureObserveState() {
        app_data.data.asObservable().filter({[weak self] (s) -> Bool in
            guard let `self` = self else { return false}
            if self.VC_TYPE == view_type.Comprehensive.rawValue {
                if s.count == AssetConfiguration.shared.asset_ids.count {
                    return true
                }
            }
            else {
                let buckets = s.filter { (homebucket) -> Bool in
                    return homebucket.base == self.base
                }
                
                if buckets.count == AssetConfiguration.shared.asset_ids.filter( { $0.base == self.base} ).count, buckets.count != 0 {
                    return true
                }
            }
            return false
        }).take(1)
            .subscribe(onNext: {[weak self] (s) in
                guard let `self` = self else { return }
                self.updateUI()
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: true)
                
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc func updateUI() {
        self.performSelector(onMainThread: #selector(self.refreshTableView), with: nil, waitUntilDone: false)// non block tracking mode
    }
    
    @objc func refreshTableView() {
        if self.isVisible {
            self.endLoading()
            if self.VC_TYPE == 1 || self.VC_TYPE == view_type.Comprehensive.rawValue{
                self.contentView?.tableView.reloadData()
                self.contentView?.tableView.isHidden = false
                self.contentView?.viewType = view_type(rawValue: self.VC_TYPE) ?? .homeContent
            }else{
                self.businessTitleView?.tableView.reloadData()
                //        self.businessTitleView?.tableView.isHidden = false
            }
        }
    }
}


extension HomeViewController {
    @objc func cellClicked(_ data:[String: Any]) {
        
        if VC_TYPE == view_type.homeContent.rawValue {//首页
            if let index = data["index"] as? Int {
                self.coordinator?.openMarket(index:index, currentBaseIndex:self.contentView!.currentBaseIndex)
            }
        }
        else if VC_TYPE == view_type.Comprehensive.rawValue {
            if let index = data["index"] as? Int {
                let datas = app_data.filterTopgainers()
                if datas.count > index {
                    let buckets = app_data.filterTopgainers()[index]
                    
                    if let baseIndex = AssetConfiguration.market_base_assets.firstIndex(of: buckets.base) {
                        let markets = app_data.filterQuoteAsset(buckets.base)
                        if let curIndex = markets.firstIndex(of: buckets) {
                            self.coordinator?.openMarket(index: curIndex, currentBaseIndex:baseIndex)
                        }
                    }
                }
            }
        }
        else{
            if let value = data["info"] as? Pair{
                if let superVC = self.parent as? TradeViewController{
                    superVC.pair = value
                }
            }
        }
    }
}







