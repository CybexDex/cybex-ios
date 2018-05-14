//
//  HomeViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import EZSwiftExtensions
import RxCocoa
import RxSwift
import ChainableAnimations
import TableFlip
import SwiftyJSON

class HomeViewController: BaseViewController, UINavigationControllerDelegate, UIScrollViewDelegate {
  
  var coordinator: (HomeCoordinatorProtocol & HomeStateManagerProtocol)?

  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    
    handlerUpdateVersion(nil)
    
    UserManager.shared.login("abc", password: "123456")
    app_coodinator.showLogin()
  }
  
  func setupUI() {    
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
    }
    
    
    self.localized_text = R.string.localizable.navWatchlist.key.localizedContainer()
    
    let cell = String.init(describing: HomePairCell.self)
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
    
    app_data.data.asObservable().distinctUntilChanged()
      .filter({$0.count == AssetConfiguration.shared.asset_ids.count})
      .subscribe(onNext: { (s) in
        DispatchQueue.main.async {
          self.tableView.reloadData()
          self.tableView.isHidden = false
        }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return app_data.data.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: HomePairCell.self), for: indexPath) as! HomePairCell
    let markets = app_data.data.value
    let data = markets[indexPath.row]
    cell.setup(data, indexPath: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
  }
}

extension HomeViewController {
  @objc func cellClicked(_ data:[String: Any]) {
    if let index = data["index"] as? Int {
      self.coordinator?.openMarket(index:index)

    }
  }

}




