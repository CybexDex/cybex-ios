//
//  YourPortfolioViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme

class YourPortfolioViewController: BaseViewController {
  struct define {
    static let sectionHeaderHeight : CGFloat = 44.0
  }
  var data : [MyPortfolioData] = [MyPortfolioData]()
  
  var coordinator: (YourPortfolioCoordinatorProtocol & YourPortfolioStateManagerProtocol)?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var imgBgView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tradeTitltView = TradeNavTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
    tradeTitltView.title.localized_text =  R.string.localizable.my_property.key.localizedContainer()
    tradeTitltView.title.textColor = UIColor.white
    tradeTitltView.icon.isHidden = true
    self.navigationItem.titleView = tradeTitltView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let image = UIImage.init(color: UIColor.clear)
    navigationController?.navigationBar.setBackgroundImage(image, for: .default)
    navigationController?.navigationBar.isTranslucent = true
    setupUI()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let nav = self.navigationController as? BaseNavigationController {
      nav.updateNavUI()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if ThemeManager.currentThemeIndex == 0 {
      UIApplication.shared.statusBarStyle = .lightContent
    } else {
      UIApplication.shared.statusBarStyle = .default
    }
  }
  
  func setupUI(){
    UIApplication.shared.statusBarStyle = .lightContent

    let height = UIScreen.main.bounds.height
    if height == 812 {
      imgBgView.image = R.image.imgMyBalanceBgX()
    } else {
      imgBgView.image = R.image.imgMyBalanceBg()
    }

    configLeftNavButton(R.image.icArrowForwardWhite16Px())
//    let cell = String.init(describing: YourPortfolioCell.self)
    let cell = R.nib.yourPortfolioCell.name
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
    
    UserManager.shared.balances.asObservable().skip(1).subscribe(onNext: {[weak self] (balances) in
      guard let `self` = self else { return }
      if let _ = UserManager.shared.balances.value{
        self.data = UserManager.shared.getMyPortfolioDatas().filter({ (folioData) -> Bool in
          return folioData.realAmount != "0" && folioData.limitAmount != "0"
        })
      }
      
      self.tableView.reloadData()
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
//    UserManager.shared.limitOrder.asObservable().skip(1).subscribe(onNext: {[weak self] (balances) in
//      guard let `self` = self else { return }
//      self.data = UserManager.shared.getMyPortfolioDatas()
//      self.tableView.reloadData()
//
//      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    app_data.otherRequestRelyData.asObservable()
      .subscribe(onNext: {[weak self] (s) in
        guard let `self` = self else { return }

        DispatchQueue.main.async {
          if let _ = UserManager.shared.balances.value{
            self.data = UserManager.shared.getMyPortfolioDatas().filter({ (folioData) -> Bool in
              return folioData.realAmount != "0" && folioData.limitAmount != "0"
            })
          }
          
          if self.data.count == 0 {
           
            self.tableView.showNoData(R.string.localizable.balance_nodata.key.localized(), icon: R.image.imgWalletNoAssert.name)
          } else {
            self.tableView.hiddenNoData()
          }
          guard self.isVisible else { return }

          self.tableView.reloadData()
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
}

extension YourPortfolioViewController : UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: YourPortfolioCell.self), for: indexPath) as! YourPortfolioCell
    
    cell.setup(self.data[indexPath.row], indexPath: indexPath)
    return cell
  }
  
//  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: define.sectionHeaderHeight))
//    lockupAssetsSectionView.cybPriceTitle.locali = R.string.localizable.cyb_value.key.localized()
//    return lockupAssetsSectionView
//  }
//  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    return define.sectionHeaderHeight
//  }
}

extension YourPortfolioViewController {
  @objc func recharge(_ data: [String: Any]) {
    self.coordinator?.pushToRechargeVC()
  }
  @objc func withdrawdeposit(_ data: [String: Any]) {
    self.coordinator?.pushToWithdrawDepositVC()
  }
  @objc func transfer(_ data: [String: Any]) {
    self.coordinator?.pushToTransferVC()
  }
}


