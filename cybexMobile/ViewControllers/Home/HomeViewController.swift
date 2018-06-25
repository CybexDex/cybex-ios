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
import ChainableAnimations
import TableFlip
import SwiftyJSON
import TinyConstraints

class HomeViewController: BaseViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
  
  var coordinator: (HomeCoordinatorProtocol & HomeStateManagerProtocol)?
  
  var pair: Pair? {
    didSet{
     
    }
  }
  
  var contentView : HomeContentView?
  var businessTitleView : BusinessTitleView?
  
  var VC_TYPE : Int = 1 {
    didSet {
      switchContainerView()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    handlerUpdateVersion(nil)
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
    if self.VC_TYPE == 1{
      contentView = HomeContentView()
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
    
    app_data.data.asObservable()
      .skip(1)
      .filter({$0.count == AssetConfiguration.shared.asset_ids.count})
      .distinctUntilChanged()
      .throttle(3, latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { (s) in
        if app_data.data.value.count == 0 {
          return
        }
        self.performSelector(onMainThread: #selector(self.refreshTableView), with: nil, waitUntilDone: false)// non block tracking mode
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  @objc func refreshTableView() {
    if self.isVisible {
      self.endLoading()
      if self.VC_TYPE == 1{
        self.contentView?.tableView.reloadData()
        self.contentView?.tableView.isHidden = false
      }else{
        self.businessTitleView?.tableView.reloadData()
        self.businessTitleView?.tableView.isHidden = false
      }
    }
  }
}


extension HomeViewController {
  @objc func cellClicked(_ data:[String: Any]) {
    if VC_TYPE == 1{
      if let index = data["index"] as? Int {
        self.coordinator?.openMarket(index:index, currentBaseIndex:self.contentView!.currentBaseIndex)
      }
    }else{
      if let value = data["info"] as? Pair{
        if let superVC = self.parent as? TradeViewController{
          superVC.pair = value
        }
      }
    }
  }
}





