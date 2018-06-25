//
//  RechargeDetailViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Localize_Swift
import AwaitKit


class RechargeDetailViewController: BaseViewController {
  
  @IBOutlet weak var avaliableView: RechargeItemView!
  @IBOutlet weak var addressView: RechargeItemView!
  @IBOutlet weak var amountView: RechargeItemView!
  
  @IBOutlet weak var gateAwayFee: UILabel!
  @IBOutlet weak var insideFee: UILabel!
  
  @IBOutlet weak var finalAmount: UILabel!
  
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var errorL: UILabel!
  
  @IBOutlet weak var feeView: UIView!
  
  @IBOutlet weak var introduceView: UIView!
    @IBOutlet weak var introduce: UITextView!
  @IBOutlet weak var withdraw: Button!
  
  var feeAssetId : String  = AssetConfiguration.CYB
  
  enum Recharge_Type : String{
    case noAuthen
    case noneMoney
    case pauseRecharge
    case normal
  }
  
  var isWithdraw : Bool = false
  var isTrueAddress : Bool = false{
    didSet{
      self.changeWithdrawState()
    }
  }
  var isAvalibaleAmount : Bool = false{
    didSet{
      self.changeWithdrawState()
    }
  }
  
  
  var balance : Balance?
  var coordinator: (RechargeDetailCoordinatorProtocol & RechargeDetailStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if Localize.currentLanguage() == "en"{
      self.title = (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)! + " Deposit"
    }else{
      self.title = (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)! + "提现"
    }
    
    setupUI()
    setupEvent()
    self.coordinator?.fetchWithDrawInfoData((app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)!)
  }
  
  func setupUI(){
    amountView.content.keyboardType = .decimalPad
    addressView.btn.isHidden        = true
    amountView.btn.setTitle(Localize.currentLanguage() == "en" ? "All" : "全部", for: .normal)
    avaliableView.content.text = String(describing: getRealAmount((self.balance?.asset_type)!, amount: (self.balance?.balance)!)) + " " + (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)!
    
    addressView.btn.addTarget(self, action: #selector(cleanAddress), for: .touchUpInside)
    amountView.btn.addTarget(self, action: #selector(addAllAmount), for: .touchUpInside)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    if !self.isWithdraw{
      if let name = app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade{
        var message = ""
        if Localize.currentLanguage() == "en"{
          message = "Stop \(String(describing: name)) charging and withdrawing\nFor details, please refer to the announcement"
        }else{
          message = "暂停\(String(describing: name))充值提现\n详情请查询公告"
        }
        ShowManager.shared.setUp(title_image: "erro16Px", message: message, animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
        ShowManager.shared.showAnimationInView(self.view)
        ShowManager.shared.hide(2)
      }
      return
    }
    
    if !UserManager.shared.isWithDraw {
      let message = R.string.localizable.withdraw_miss_authority.key.localized()
      ShowManager.shared.setUp(title_image: "erro16Px", message: message, animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
      return
    }
  }
  
  
  func setupEvent(){
    self.withdraw.button.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: amountView.content, queue: nil) { [weak self](notification) in
      guard let `self` = self else {return}
      
      if let amount = self.amountView.content.text?.toDouble(),amount > 0{
        let avaliable = getRealAmount((self.balance?.asset_type)!, amount: (self.balance?.balance)!)
        if let minValue = self.coordinator?.state.property.data.value?.minValue{
          if amount < minValue {
            self.isAvalibaleAmount = false
            self.errorView.isHidden = false
            self.errorL.locali =  R.string.localizable.withdraw_min_value.key.localized()
          }else if amount + (self.coordinator?.state.property.data.value?.fee)! > avaliable {
            self.isAvalibaleAmount = false
            self.errorView.isHidden = false
            self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
          }else{
            self.isAvalibaleAmount = true
            if let fee = self.coordinator?.state.property.data.value?.fee{
              self.finalAmount.text = String(describing: avaliable - amount - fee)
            }
          }
        }
      }
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: addressView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{return}
      if self.addressView.content.text != nil && (self.addressView.content.text?.count)! > 0 {
        self.addressView.btn.isHidden = false
      }else{
        self.addressView.btn.isHidden = true
      }
      if let assetName = app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade,let address = self.addressView.content.text{
        if (self.coordinator?.verifyAddress(assetName, address: address) == true){
          self.isTrueAddress = true
          self.errorView.isHidden = true
        }else{
          self.isTrueAddress = false
          self.errorView.isHidden = false
          self.errorL.locali =  R.string.localizable.withdraw_address.key.localized()
        }
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
    
    self.coordinator?.state.property.data.asObservable().skip(1).subscribe(onNext: {[weak self] (withdrawInfo) in
      guard let `self` = self else{return}
      if let data = withdrawInfo{
        self.insideFee.text = String(describing: data.fee) + " " + (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)!
        print("minValue : \(data.minValue)")
        self.amountView.textplaceholder = Localize.currentLanguage() == "en" ? "Min" + String(describing: data.minValue) : "最小提现数量 " + String(describing: data.minValue)
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    self.coordinator?.state.property.gatewayFee.asObservable().subscribe(onNext: { [weak self](fee) in
      guard let `self` = self else{ return }
      
       if let fee = fee, let asset = app_data.assetInfo[self.feeAssetId]{
        let feeAmount = getRealAmount(fee.asset_id, amount: fee.amount)
        if let balances = UserManager.shared.balances.value {
          for balance in balances{
            if balance.asset_type == AssetConfiguration.CYB{
              let cybAmount = getRealAmount(balance.asset_type, amount: balance.balance)
              if feeAmount <= cybAmount{
                self.gateAwayFee.text = String(describing:feeAmount).formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade
              }else{
                self.feeAssetId = (self.balance?.asset_type)!
                self.coordinator?.getGatewayFee((self.balance?.asset_type)!, amount: self.amountView.content.text!, feeAssetID: self.feeAssetId, address: self.addressView.content.text!)
              }
              return
            }
          }
        }
        let realAmount = getRealAmount((self.balance?.asset_type)!, amount: (self.balance?.balance)!)
        if realAmount < feeAmount{
          self.amountView.content.text = ""
          self.isAvalibaleAmount = false
        }else{
          self.isAvalibaleAmount = true
        }
      }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
}

extension RechargeDetailViewController{
  func changeWithdrawState(){
//    if self.isWithdraw,UserManager.shared.isWithDraw,self.isTrueAddress,self.isAvalibaleAmount{
      self.withdraw.isEnable = true
      self.coordinator?.getGatewayFee((self.balance?.asset_type)!, amount: self.amountView.content.text!, feeAssetID: AssetConfiguration.CYB, address: self.addressView.content.text!)

//    }else{
//      self.withdraw.isEnable = false
//    }
  }
  
  @objc func cleanAddress() {
    self.addressView.content.text = ""
  }
  @objc func addAllAmount(){
    if let fee = self.coordinator?.state.property.data.value?.fee{
      self.amountView.content.text = String(describing: getRealAmount((self.balance?.asset_type)!, amount: (self.balance?.balance)!) - fee)
      self.finalAmount.text = self.amountView.content.text
    }
  }
  
  @objc func keyboardWillShow(){
    self.feeView.subviews.forEach { (view) in
      view.isHidden = true
    }
    self.introduceView.subviews.forEach { (view) in
      view.isHidden = true
    }
    self.feeView.isHidden = true
    self.introduceView.isHidden = true
  }
  
  @objc func keyboardWillHidden(){
    self.feeView.isHidden = false
    self.introduceView.isHidden = false
    self.feeView.subviews.forEach { (view) in
      view.isHidden = false
    }
    self.introduceView.subviews.forEach { (view) in
      view.isHidden = false
    }
  }
  @objc func withDrawAction(){
    
  }
}
