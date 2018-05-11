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
import EZSwiftExtensions

class TradeHistoryViewController: BaseViewController {
  @IBOutlet weak var tableView: UITableView!
  
    @IBOutlet weak var quote_name: UILabel!
    @IBOutlet weak var base_name: UILabel!
    
    var coordinator: (TradeHistoryCoordinatorProtocol & TradeHistoryStateManagerProtocol)?
  
  var pair:Pair? {
    didSet {
      if self.tableView != nil, oldValue != pair {
        self.tableView.isHidden = true
      }
     
      let base_info = app_data.assetInfo[pair!.base]!
      let quote_info = app_data.assetInfo[pair!.quote]!

      self.quote_name.text = quote_info.symbol
      self.base_name.text = base_info.symbol
      self.coordinator?.fetchData(pair!)

    }
  }
  
  var data:[(Bool, String, String, String, String)] = []

	override func viewDidLoad() {
    super.viewDidLoad()
    
    let cell = String.init(describing: TradeHistoryCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
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
          
          self.tableView.reloadData()
          self.tableView.layoutIfNeeded()
          
          self.coordinator?.updateMarketListHeight(500)
          self.tableView.isHidden = false
          
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
        let base_precision = pow(10, base_info.precision.toDouble)
        let quote_precision = pow(10, quote_info.precision.toDouble)
        
        if pay["asset_id"].stringValue == pair!.base {
          let quote_volume = Double(receive["amount"].stringValue)! / quote_precision
          let base_volume = Double(pay["amount"].stringValue)! / base_precision
          
          let price = base_volume / quote_volume
          let isCYB = base_info.id == AssetConfiguration.CYB
          showData.append((false, price.toString.formatCurrency(digitNum: isCYB ? 5 : 8), quote_volume.toString.suffixNumber(digitNum:quote_info.precision), base_volume.toString.suffixNumber(digitNum: base_info.precision), time.dateFromISO8601!.toString(format: "MM/dd HH:mm:ss")))
        }
        else {
          let quote_volume = Double(pay["amount"].stringValue)! / quote_precision
          let base_volume = Double(receive["amount"].stringValue)! / base_precision
          
          let price = base_volume / quote_volume
          let isCYB = base_info.id == AssetConfiguration.CYB
          showData.append((true, price.toString.formatCurrency(digitNum: isCYB ? 5 : 8), quote_volume.toString.suffixNumber(digitNum: quote_info.precision), base_volume.toString.suffixNumber(digitNum: base_info.precision), time.dateFromISO8601!.toString(format: "MM/dd HH:mm:ss")))
        }
        
      }
      
      self.data = showData

    }
  }
  
  deinit {
    print("trade history dealloc")
  }
}

extension TradeHistoryViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.data.count / 2
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: TradeHistoryCell.self), for: indexPath) as! TradeHistoryCell
    cell.setup(self.data[(indexPath.row + 1) * 2 - 2], indexPath: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
  }
}
