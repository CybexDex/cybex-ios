//
//  TransferListViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class TransferListViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
	var coordinator: (TransferListCoordinatorProtocol & TransferListStateManagerProtocol)?
  var data : [(TransferRecord,time:String)]?
  
	override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
      self.title = R.string.localizable.transfer_title()
        let nibString = String(describing: TransferListCell.self)
        self.tableView.register(UINib(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
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
      UserManager.shared.transferRecords.asObservable().subscribe(onNext: { [weak self](data) in
        guard let `self` = self ,let data = data else { return }
        self.data = data
        if self.isVisible {
          self.tableView.reloadData()
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension TransferListViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if let data = self.data {
        return data.count
      }
      return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellString = String(describing: TransferListCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellString, for: indexPath) as! TransferListCell
        cell.setup(self.data![indexPath.row], indexPath: indexPath)
        return cell
    }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.coordinator?.openTransferDetail(nil)
  }
    
}
