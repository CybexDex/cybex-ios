//
//  AccountViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftTheme
import AwaitKit
import RxSwift
import IGIdenticon

class AccountViewController: BaseViewController {
  // 定义整个界面的全部子界面，根据tag值从stackView上面获取不同的界面
  enum view_type:Int {
    case header_view          = 0
    case login_view           = 1
    case introduce_view       = 2
    case hello_view           = 3
    case member_view          = 4
    case totalBalance_view    = 5
    case yourBanlance_view    = 6
    case yourPortfolio_view   = 7
    case assetOperations_view = 8
  }
  
  enum user_type:Int{
    case unLogin     = 0
    case unPortfolio = 1
    case normalState = 2
  }
  
  @IBOutlet weak var portfolioView: AccountPortfolioView!
  @IBOutlet weak var nameL: UILabel!
  
  @IBOutlet weak var memberLevelView: UIView!
  @IBOutlet weak var memberLevel: UILabel!
  
  @IBOutlet weak var totalBalance: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var loginArrowImgView: UIImageView!
  @IBOutlet weak var accountImageView: UIImageView!
  
  var coordinator: (AccountCoordinatorProtocol & AccountStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupEvent()
  }
  
  // UI的初始化设置
  func setupUI(){
    self.automaticallyAdjustsScrollViewInsets = false
    self.localized_text = R.string.localizable.accountTitle.key.localizedContainer()
    configRightNavButton()
    setupUIWithStatus(user_type.normalState)
  }
  
  func setupEvent() {
    if let login_view = stackView.viewWithTag(view_type.login_view.rawValue) {
      login_view.rx.tapGesture().when(.recognized).subscribe(onNext: { (tap) in
        app_coodinator.showLogin()
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
  }
  
  // 跳转到设置界面
  override func rightAction(_ sender: UIButton) {
    self.coordinator?.openSetting()
  }
  
  fileprivate func setupUIWithStatus(_ sender : user_type){
    var tags : [Int] = []
    switch sender {
    case .unLogin:
      tags = Array(view_type.hello_view.rawValue...view_type.assetOperations_view.rawValue)
      for tag in tags {
        stackView.viewWithTag(tag)?.isHidden = true
      }
      loginArrowImgView.image = UIImage(named: "ic_arrow_forward_16px")?.withColor(ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo)
    case .unPortfolio:
      tags = [view_type.login_view.rawValue,view_type.introduce_view.rawValue,view_type.yourPortfolio_view.rawValue]
      for tag in tags {
        stackView.viewWithTag(tag)?.isHidden = true
      }
    case .normalState:
      tags = [view_type.login_view.rawValue,view_type.introduce_view.rawValue]
      for tag in [1,2]{
        stackView.viewWithTag(tag)?.isHidden = true
      }
    }
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
  
  func updataView(){
    nameL.text =  UserManager.shared.account.value?.name
    
    let isSuper = UserManager.shared.account.value?.superMember ?? false
    memberLevel.localized_text = isSuper ? R.string.localizable.accountSuperMember.key.localizedContainer() :  R.string.localizable.accountBasicMember.key.localizedContainer()
    totalBalance.text = UserManager.shared.balance.toString
    
    accountImageView.image = Identicon().icon(from: UserManager.shared.avatarString!, size: CGSize(width: 56, height: 56))
  
    portfolioView.data = UserManager.shared.balances.value!
  }
  
  
  
  func updataStatus(){
    defer {
      updataView()
    }
    //  判断是否有name来断定是否登陆
    guard let _ =  UserManager.shared.account.value else {
      setupUIWithStatus(user_type.unLogin)
      return
    }
    //  判断是否有可用资产来断定是否显示可用资产
    guard let _ =  UserManager.shared.balances.value else {
      setupUIWithStatus(user_type.unPortfolio)
      return
    }
    setupUIWithStatus(user_type.normalState)
  }
  
  override func configureObserveState() {
    commonObserveState()
    
    UserManager.shared.account.asObservable().subscribe(onNext: { [weak self](account) in
      guard let `self` = self else{ return }
      self.updataStatus()
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    UserManager.shared.limitOrder.asObservable().subscribe(onNext: { [weak self](account) in
      guard let `self` = self else{ return }
      self.updataStatus()
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    UserManager.shared.balances.asObservable().subscribe(onNext: { [weak self](account) in
      guard let `self` = self else{ return }
      self.updataStatus()
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
}



extension AccountViewController{
  @objc func openPortfolio(_ data:[String: Any]){
    self.coordinator?.openYourProtfolio()
  }
  @objc func openOpenedOrders(_ data:[String: Any]){
    self.coordinator?.openOpenedOrders()
  }
  @objc func openLockupAssets(_ data:[String: Any]){
    self.coordinator?.openLockupAssets()
  }
}
