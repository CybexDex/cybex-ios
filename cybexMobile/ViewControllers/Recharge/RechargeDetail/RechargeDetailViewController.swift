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
  
  
  enum Recharge_Type : String{
    case noAuthen
    case noneMoney
    case pauseRecharge
    case normal
  }
  
  var isWithdraw : Bool = false
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
    self.coordinator?.fetchWithDrawInfoData("ETH")
  }
  
  func setupUI(){
    amountView.content.keyboardType = .decimalPad
    addressView.btn.isHidden        = true
    amountView.btn.setTitle(Localize.currentLanguage() == "en" ? "All" : "全部", for: .normal)
    avaliableView.content.text = String(describing: getRealAmount((self.balance?.asset_type)!, amount: (self.balance?.balance)!)) + " " + (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)!
    
    if !self.isWithdraw{
      if let name = app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade{
        var message = ""
        if Localize.currentLanguage() == "en"{
          message = ""
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
      ShowManager.shared.setUp(title_image: "erro16Px", message: "没有提现权限", animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
      return
    }
    
    addressView.btn.addTarget(self, action: #selector(cleanAddress), for: .touchUpInside)
    amountView.btn.addTarget(self, action: #selector(addAllAmount), for: .touchUpInside)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  
  func setupEvent(){
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: amountView.content, queue: nil) { [weak self](notification) in
      guard let `self` = self else {return}
      
      if let amount = self.amountView.content.text?.toDouble(){
        let avaliable = getRealAmount((self.balance?.asset_type)!, amount: (self.balance?.balance)!)
        if let minValue = self.coordinator?.state.property.data.value?.minValue{
          if amount < minValue {
            self.errorView.isHidden = false
            self.errorL.locali =  R.string.localizable.withdraw_min_value.key.localized()
          }else if amount + (self.coordinator?.state.property.data.value?.fee)! > avaliable {
            self.errorView.isHidden = false
            self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
          }else{
            self.errorView.isHidden = true
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
          self.errorView.isHidden = true
        }else{
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
        self.insideFee.text = String(describing: data.fee) + (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)!
        
        self.amountView.textplaceholder = Localize.currentLanguage() == "en" ? "Min" + String(describing: data.minValue) : "最小提现数量 " + String(describing: data.minValue)
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
}

extension RechargeDetailViewController{
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
}
