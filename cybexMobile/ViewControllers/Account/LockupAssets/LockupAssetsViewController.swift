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
import TinyConstraints
import EZSwiftExtensions
import SwiftyJSON

class LockupAssetsViewController: BaseViewController {
  
  struct define {
    static let sectionHeaderHeight : CGFloat = 44.0
   }
  
  @IBOutlet weak var tableView: UITableView!
  var coordinator: (LockupAssetsCoordinatorProtocol & LockupAssetsStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    self.coordinator?.fetchLockupAssetsData(["CYBLanbfQMeMHCkowkpD7CDV2t36WfXfLnrh","CYB4J4j9KHhBKqvZZjPBigQRvBpR7HeKPFWG","CYBQ3sXxGwruu2nW9ynBvz5F8JciGMwmkiBY","CYBCWPGM3BhteRySUGfsf3xmjX9HJYPh3LUf","CYBHB2VMQV6exMeAzWBQq1vnRnDeuTWR3FyF", "CYB7e4T1W7mgCYXV6zZzkFariBAxrpp3BFnB","CYBBRnktyjxJ3W6zPofMZyxYspfXHrLjj2ph", "CYBHWS8zr367xfRAABbjBZTc76rgHr6LdSn3", "CYBCkKVtNtwLktgBh8gCKPsmoD1AvWUnjF4q"])

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
    self.coordinator?.state.property.data.asObservable().distinctUntilChanged().skip(1).subscribe(onNext:{[weak self] (s) in
      guard let `self` = self else{return}
      self.tableView.reloadData()
      self.tableView.layoutIfNeeded()
      },onError:nil,onCompleted:nil,onDisposed:nil).disposed(by:disposeBag)
  }
}

// MARK: UITableViewDataSource

extension LockupAssetsViewController : UITableViewDataSource ,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let data = coordinator!.state.property.data.value
    return data.datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:LockupAssetsCell.self), for: indexPath) as! LockupAssetsCell
    let data = coordinator!.state.property.data.value
    
    cell.setup(data.datas[indexPath.row], indexPath: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, w: self.view.width, h: define.sectionHeaderHeight))
    
    return lockupAssetsSectionView
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return define.sectionHeaderHeight
  }
  
}
