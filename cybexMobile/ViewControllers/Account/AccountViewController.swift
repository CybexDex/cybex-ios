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
import CryptoSwift
import SwiftRichString

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
    case noDataState = 3
  }
  
  @IBOutlet weak var portfolioView: AccountPortfolioView!
  @IBOutlet weak var nameL: UILabel!
  
  @IBOutlet weak var memberLevel: UILabel!
  
  @IBOutlet weak var totalBalance: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  
  @IBOutlet weak var accountImageView: UIImageView!
  
  @IBOutlet weak var balanceRMB: UILabel!
  
  @IBOutlet weak var bgImageView: UIImageView!
  
  
  @IBOutlet weak var introduceCybex: UILabel!
  
  @IBOutlet weak var balanceIntroduce: UIImageView!
  
  var coordinator: (AccountCoordinatorProtocol & AccountStateManagerProtocol)?
  
  var balanceIntroduceView : BalanceIntroduceView {
    get{
      let biView = BalanceIntroduceView(frame: UIScreen.main.bounds)
      UIApplication.shared.keyWindow?.addSubview(biView)
      return biView
    }
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupEvent()
    if  UserManager.shared.isLoginIn {
      setupUIWithStatus(user_type.noDataState)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updataStatus()
  }
  
  // UI的初始化设置
  func setupUI(){
    self.automaticallyAdjustsScrollViewInsets = false
    configRightNavButton()
    //    balanceIntroduce.image = UIImage(named: "cloudWallet")?.tint(.steel, blendMode: .normal)
    
    self.balanceIntroduce.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self](tap) in
      
      guard let `self` = self else {return}
      let _ = self.balanceIntroduceView
      
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
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
    for tag in view_type.header_view.rawValue...view_type.assetOperations_view.rawValue {
      stackView.viewWithTag(tag)?.isHidden = false
    }
    
    var tags : [Int] = []
    switch sender {
    case .unLogin:
      tags = Array(view_type.hello_view.rawValue...view_type.assetOperations_view.rawValue)
      for tag in tags {
        stackView.viewWithTag(tag)?.isHidden = true
      }
      
      bgImageView.isHidden    = false
      introduceCybex.styledText = R.string.localizable.accountIntroduce.key.localized()
      
    case .unPortfolio:
      tags = [view_type.login_view.rawValue,view_type.introduce_view.rawValue,view_type.yourPortfolio_view.rawValue]
      for tag in tags {
        stackView.viewWithTag(tag)?.isHidden = true
      }
      bgImageView.isHidden    = true
      
    case .normalState:
      tags = [view_type.login_view.rawValue,view_type.introduce_view.rawValue]
      for tag in [1,2]{
        stackView.viewWithTag(tag)?.isHidden = true
      }
      bgImageView.isHidden    = true
    case .noDataState:
      tags = [1,2,4,5,6,7,8]
      for tag in tags{
        stackView.viewWithTag(tag)?.isHidden = true
      }
      nameL.text =  UserManager.shared.name
      let hash = UserManager.shared.avatarString!
      let generator = IconGenerator(size: 168, hash: Data(hex: hash))
      let image = UIImage(cgImage: generator.render()!)
      accountImageView.image = image
      
      bgImageView.isHidden    = true
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
  
  func updataView(_ isLogin:Bool){
    if !isLogin{
      accountImageView.image = #imageLiteral(resourceName: "accountAvatar")
      return
    }
    nameL.text =  UserManager.shared.account.value?.name
    
    let isSuper = UserManager.shared.account.value?.superMember ?? false
    memberLevel.localized_text = isSuper ? R.string.localizable.accountSuperMember.key.localizedContainer() :  R.string.localizable.accountBasicMember.key.localizedContainer()
    if UserManager.shared.balance == 0 {
        totalBalance.text = "--"
    }else{
        totalBalance.text = UserManager.shared.balance.formatCurrency(digitNum: 5)
    }
    
    if let ethAmount = changeToETHAndCYB(AssetConfiguration.CYB).eth.toDouble(){
        if UserManager.shared.balance == 0 {
            balanceRMB.text   = "≈¥--"
        }else{
            balanceRMB.text   = "≈¥" + String(UserManager.shared.balance * ethAmount * app_state.property.eth_rmb_price).formatCurrency(digitNum: 2)
        }
    }
    
    if isLogin {
      if let hash = UserManager.shared.avatarString {
        let generator = IconGenerator(size: 168, hash: Data(hex: hash))
        if let render = generator.render() {
          let image = UIImage(cgImage: render)
          accountImageView.image = image
        }
      }
    }
    else {
      accountImageView.image =  #imageLiteral(resourceName: "accountAvatar")
    }
  }
  
  
  
  func updataStatus(){
    
    //  判断是否有name来断定是否登陆
    guard let _ =  UserManager.shared.account.value else {
      setupUIWithStatus(user_type.unLogin)
      updataView(false)
      
      return
    }
    //  判断是否有可用资产来断定是否显示可用资产
    guard let balances =  UserManager.shared.balances.value, balances.count > 0  else {
      setupUIWithStatus(user_type.unPortfolio)
      updataView(true)
      
      return
    }
    setupUIWithStatus(user_type.normalState)
    updataView(true)
    
    portfolioView.data = UserManager.shared.getPortfolioDatas()
  }
  
  override func configureObserveState() {
    commonObserveState()
    
    UserManager.shared.account.asObservable()
      .skip(1)
      .throttle(10, latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self](account) in
        guard let `self` = self else{ return }
        if self.isVisible {
          self.updataStatus()
        }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    UserManager.shared.limitOrder.asObservable()
      .skip(1)
      .throttle(10, latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self](account) in
        guard let `self` = self else{ return }
        if self.isVisible {
          self.updataStatus()
        }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    UserManager.shared.balances.asObservable()
      .skip(1)
      .throttle(10, latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self](account) in
        guard let `self` = self else{ return }
        if self.isVisible {
          self.updataStatus()
        }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
}



extension AccountViewController{
  @objc func openPortfolio(_ data:[String: Any]){
    self.coordinator?.openYourProtfolio()
  }
  @objc func openOpenedOrders(_ data:[String: Any]){
//    self.coordinator?.openOpenedOrders()
    self.coordinator?.openRecharge()
  }
  @objc func openLockupAssets(_ data:[String: Any]){
    self.coordinator?.openLockupAssets()
  }
}
