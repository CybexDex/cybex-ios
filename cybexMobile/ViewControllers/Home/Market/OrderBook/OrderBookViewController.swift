//
//  OrderBookViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import TinyConstraints
import SwiftyJSON
import Localize_Swift


class OrderBookViewController: BaseViewController {
  
  var coordinator: (OrderBookCoordinatorProtocol & OrderBookStateManagerProtocol)?
  
  var contentView : OrderBookContentView!
  var tradeView : TradeView!
  var VC_TYPE : Int = 1
  var pair:Pair? {
    didSet {
      guard let pair = pair, let base_info = app_data.assetInfo[pair.base], let quote_info = app_data.assetInfo[pair.quote] else { return }
      
      if self.tradeView != nil{
        // orderbook_price
        self.tradeView.titlePrice.text = R.string.localizable.orderbook_price.key.localized()
        self.tradeView.titleAmount.text = R.string.localizable.orderbook_amount.key.localized()
      }
      self.coordinator?.fetchData(pair)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  func setupUI(){
    if VC_TYPE == 1{
      contentView = OrderBookContentView(frame: .zero)
      self.view.addSubview(contentView)
      contentView.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }else{
      tradeView = TradeView(frame:self.view.bounds)
      self.view.addSubview(tradeView)
      tradeView.edges(to: self.view, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
      
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
    
    self.coordinator!.state.property.data.asObservable().skip(1).distinctUntilChanged()
      .subscribe(onNext: {[weak self] (s) in
        guard let `self` = self else { return }
        if self.VC_TYPE == 1{
          self.contentView.data = s
          self.contentView.tableView.reloadData()
          self.contentView.tableView.isHidden = false
          self.coordinator?.updateMarketListHeight(500)
        }else{
            self.tradeView.data = s
          let base_eth = changeToETHAndCYB(self.pair!.base).eth
          let quote_eth = changeToETHAndCYB(self.pair!.quote).eth
          
          
          self.tradeView.rmbPrice.text = "≈¥" + String(describing: quote_eth.toDouble()! * app_state.property.eth_rmb_price).formatCurrency(digitNum: 2)
         
          self.tradeView.amount.text = String(describing: (quote_eth.toDouble()! / base_eth.toDouble()!)).formatCurrency(digitNum: (app_data.assetInfo[self.pair!.base]?.precision)!)
        }
        
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }  
}

extension OrderBookViewController : TradePair{
  var pariInfo: Pair {
    get {
      return self.pair!
    }
    set {
      self.pair = newValue
    }
  }
}


