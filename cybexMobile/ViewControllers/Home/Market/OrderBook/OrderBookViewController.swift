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
import EZSwiftExtensions
import SwiftyJSON

class OrderBookViewController: BaseViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var coordinator: (OrderBookCoordinatorProtocol & OrderBookStateManagerProtocol)?
  
  var pair:Pair? {
    didSet {
      if self.tableView != nil, oldValue != pair {
        self.tableView.isHidden = true
      }
      self.coordinator?.fetchData(pair!)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cell = String.init(describing: OrderBookCell.self)
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
    
    self.coordinator!.state.property.data.asObservable().distinctUntilChanged()
      .subscribe(onNext: {[weak self] (s) in
        guard let `self` = self else { return }
        
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        
        
        self.coordinator?.updateMarketListHeight(500)
        self.tableView.isHidden = false
        
        
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  

}

extension OrderBookViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let data = coordinator!.state.property.data.value
    return max(data.asks.count, data.bids.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: OrderBookCell.self), for: indexPath) as! OrderBookCell
    
    let data = coordinator!.state.property.data.value
    
    cell.setup((data.bids[optional:indexPath.row], data.asks[optional:indexPath.row]), indexPath: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
  }
}
