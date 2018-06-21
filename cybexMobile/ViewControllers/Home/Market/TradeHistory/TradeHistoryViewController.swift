//
//  TradeHistoryViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift

class TradeHistoryViewController: BaseViewController {
  
  @IBOutlet weak var historyView: TradeHistoryView!
  
  var coordinator: (TradeHistoryCoordinatorProtocol & TradeHistoryStateManagerProtocol)?
  
  var pair:Pair? {
    didSet {
      let base_info = app_data.assetInfo[(pair?.base)!]!
      let quote_info = app_data.assetInfo[(pair?.quote)!]!
      if Localize.currentLanguage() == "en"{
        self.historyView.price.text  = "Price\(base_info.symbol.filterJade)"
        self.historyView.amount.text = "Amount\(quote_info.symbol.filterJade)"
        self.historyView.sellAmount.text = "Total\(base_info.symbol.filterJade)"
      }else{
        self.historyView.price.text  = "价格\(base_info.symbol.filterJade)"
        self.historyView.amount.text = "数量\(quote_info.symbol.filterJade)"
        self.historyView.sellAmount.text = "成交额\(base_info.symbol.filterJade)"
      }
     
      self.coordinator?.fetchData(pair!)
    }
  }
  
  var data:[(Bool, String, String, String, String)]?{
    didSet{
      if self.historyView != nil{
        self.historyView.data = data
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    
    self.coordinator!.state.property.data.asObservable()
      .subscribe(onNext: {[weak self] (s) in
        guard let `self` = self else { return }
        
        self.convertToData()
        self.coordinator?.updateMarketListHeight(500)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
  }
  
  func convertToData() {
    if let data = self.coordinator?.state.property.data.value {
      var showData:[(Bool, String, String, String, String)] = []
      
      for d in data {
        let curData = d
        
        let pay = curData[0]
        let receive = curData[1]
        let time = curData[2].stringValue
        
        let base_info = app_data.assetInfo[pair!.base]!
        let quote_info = app_data.assetInfo[pair!.quote]!
        let base_precision = pow(10, base_info.precision.double)
        let quote_precision = pow(10, quote_info.precision.double)
        
        if pay["asset_id"].stringValue == pair?.base {
          let quote_volume = Double(receive["amount"].stringValue)! / quote_precision
          let base_volume = Double(pay["amount"].stringValue)! / base_precision
          
          let price = base_volume / quote_volume
          let isCYB = base_info.id == AssetConfiguration.CYB
          showData.append((false, price.formatCurrency(digitNum: isCYB ? 5 : 8), quote_volume.suffixNumber(digitNum:quote_info.precision), base_volume.suffixNumber(digitNum: base_info.precision), time.dateFromISO8601!.string(withFormat: "MM/dd HH:mm:ss")))
        }
        else {
          let quote_volume = Double(pay["amount"].stringValue)! / quote_precision
          let base_volume = Double(receive["amount"].stringValue)! / base_precision
          
          let price = base_volume / quote_volume
          let isCYB = base_info.id == AssetConfiguration.CYB
          showData.append((true, price.formatCurrency(digitNum: isCYB ? 5 : 8), quote_volume.suffixNumber(digitNum: quote_info.precision), base_volume.suffixNumber(digitNum: base_info.precision), time.dateFromISO8601!.string(withFormat: "MM/dd HH:mm:ss")))
        }
        
      }
      self.data = showData
    }
  }
}
extension TradeHistoryViewController : TradePair{
  var pariInfo: Pair {
    get {
      return self.pair!
    }
    set {
      self.pair = newValue
    }
  }
}


