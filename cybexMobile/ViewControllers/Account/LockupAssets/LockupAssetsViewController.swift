//
//  LockupAssetsViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class LockupAssetsViewController: BaseViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var coordinator: (LockupAssetsCoordinatorProtocol & LockupAssetsStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI(){
    self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
    self.localized_text = R.string.localizable.lockupAssetsTitle.key.localizedContainer()
    let cell = String.init(describing:LockupAssetsCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
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
    
  }
}

// MARK: UITableViewDataSource

extension LockupAssetsViewController : UITableViewDataSource ,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:LockupAssetsCell.self), for: indexPath) as! LockupAssetsCell
    cell.setup(nil, indexPath: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let lockupAssetsSectionView = LockupAssetsSectionView()
    
    return lockupAssetsSectionView
  }
}
