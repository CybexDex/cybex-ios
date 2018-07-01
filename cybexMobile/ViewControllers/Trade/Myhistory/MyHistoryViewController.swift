//
//  MyHistoryViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class MyHistoryViewController: BaseViewController {
  struct define {
    static let sectionHeaderHeight : CGFloat = 44.0
  }
  
  var pair: Pair? {
    didSet {
      if let data = UserManager.shared.fillOrder.value{
        self.data = data
      }
    }
  }
  var data : [(FillOrder,String)]?{
    didSet{
      
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  var coordinator: (MyHistoryCoordinatorProtocol & MyHistoryStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI(){
    self.localized_text = R.string.localizable.my_history_title.key.localizedContainer()
    let name = String.init(describing:MyHistoryCell.self)
    
    tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
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
    
    UserManager.shared.fillOrder.asObservable()
      .skip(1)
      .throttle(10, latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self](account) in
        guard let `self` = self else{ return }
        
        if let data = UserManager.shared.fillOrder.value{
          if data.count == 0{
            self.view.showNoData(R.string.localizable.myhistory_nodata.key.localized())
          }else{
            self.view.hiddenNoData()
          }
          self.data = data
          if self.isVisible{
            self.tableView.reloadData()
          }
        }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
}

extension MyHistoryViewController : UITableViewDelegate,UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.data?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let name = String.init(describing:MyHistoryCell.self)
    let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as! MyHistoryCell
    if let fillOrders = self.data {
      cell.setup(fillOrders[indexPath.row], indexPath: indexPath)
    }
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: define.sectionHeaderHeight))
    
    lockupAssetsSectionView.totalTitle.locali = R.string.localizable.order_history_first_title.key.localized()
    lockupAssetsSectionView.cybPriceTitle.locali = R.string.localizable.order_history_second_title.key.localized()
    return lockupAssetsSectionView
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return define.sectionHeaderHeight
  }
  
}
