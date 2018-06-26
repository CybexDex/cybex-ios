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
  @IBOutlet weak var stackView: UIStackView!
  
  var feeAssetId : String  = AssetConfiguration.CYB
  
  var isWithdraw : Bool = false
  var isTrueAddress : Bool = false{
    didSet{
      if isTrueAddress != oldValue{
        self.changeWithdrawState()
      }
    }
  }
  var isAvalibaleAmount : Bool = false{
    didSet{
      if isAvalibaleAmount != oldValue{
        self.changeWithdrawState()
      }
    }
  }
  var trade : Trade?{
    didSet{
      if let balances = UserManager.shared.balances.value{
        for balance in balances{
          if balance.asset_type == trade?.id{
            self.balance = balance
          }
        }
      }
    }
  }
  var balance : Balance?
  var coordinator: (RechargeDetailCoordinatorProtocol & RechargeDetailStateManagerProtocol)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)! + R.string.localizable.recharge_title.key.localized()
    setupUI()
    checkState()
    setupEvent()
    self.coordinator?.fetchWithDrawInfoData((app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!)
  }
  
  func setupUI(){
    self.coordinator?.fetchWithDrawMessage(callback: { (message) in
      self.introduce.text = message
    })
    amountView.content.keyboardType = .decimalPad
    addressView.btn.isHidden        = true
    amountView.btn.setTitle(R.string.localizable.openedAll.key.localized(), for: .normal)
    if let balance = self.balance{
      avaliableView.content.text = String(describing: getRealAmount(balance.asset_type, amount: balance.balance)) + " " + (app_data.assetInfo[balance.asset_type]?.symbol.filterJade)!
    }else{
      avaliableView.content.text = "--" + (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!
    }
    self.withdraw.isEnable = false
    self.withdraw.button.isUserInteractionEnabled = false
    self.withdraw.button.isEnabled = false
    addressView.btn.addTarget(self, action: #selector(cleanAddress), for: .touchUpInside)
    amountView.btn.addTarget(self, action: #selector(addAllAmount), for: .touchUpInside)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
  }
  
  func checkState(){
    if !self.isWithdraw{
      self.checkIsWithdraw()
      return
    }
    if UserManager.shared.isLocked{
      self.checkLock()
      return
    }
    if !UserManager.shared.isWithDraw{
      self.checkIsAuthory()
      return
    }
  }
  
  func checkIsWithdraw(){
    if let name = app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade{
      var message = ""
      if Localize.currentLanguage() == "en"{
        message = "Unable to withdraw \(String(describing: name)) for a short time, please retry later"
      }else{
        message = "\(String(describing: name))暂停提现"
      }
      ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: message, animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(1)
    }
  }
  
  func checkLock(){
    let title = R.string.localizable.withdraw_unlock_wallet.key.localized()
    ShowManager.shared.setUp(title: title, contentView: CybexPasswordView(frame: .zero), animationType: .up_down)
    ShowManager.shared.delegate = self
    ShowManager.shared.showAnimationInView(self.view)
    
  }
  
  func checkIsAuthory(){
    let message = R.string.localizable.withdraw_miss_authority.key.localized()
    ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: message, animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
    ShowManager.shared.showAnimationInView(self.view)
    ShowManager.shared.hide(1)
    
  }
  
  
  func setupEvent(){
    self.withdraw.button.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: amountView.content, queue: nil) { [weak self](notification) in
      guard let `self` = self else {return}
      if let amount = self.amountView.content.text?.toDouble(),amount > 0{
        if let balance = self.balance{
          let avaliable = getRealAmount(balance.asset_type, amount: balance.balance)
          if let data = self.coordinator?.state.property.data.value{
            if amount < data.minValue{
              self.isAvalibaleAmount  = false
              self.errorView.isHidden = false
              self.errorL.locali      =  R.string.localizable.withdraw_min_value.key.localized()
            }else if amount > avaliable || avaliable < data.fee{
              self.isAvalibaleAmount  = false
              self.errorView.isHidden = false
              self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
            }else{
              self.isAvalibaleAmount  = true
              self.errorView.isHidden = true
              if let name = app_data.assetInfo[balance.asset_type]?.symbol.filterJade{
                self.finalAmount.text = String(amount - data.fee) + " " + name
              }
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
      if let balance = self.balance{
        if let assetName = app_data.assetInfo[balance.asset_type]?.symbol.filterJade,let address = self.addressView.content.text{
          if (self.coordinator?.verifyAddress(assetName, address: address) == true){
            self.isTrueAddress      = true
            self.errorView.isHidden = true
          }else{
            self.isTrueAddress = false
            self.errorView.isHidden = false
            self.errorL.locali =  R.string.localizable.withdraw_address_fault.key.localized()
          }
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
        self.insideFee.text = String(describing: data.fee) + " " + (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!
        print("minValue : \(data.minValue)")
        
        self.amountView.textplaceholder = R.string.localizable.recharge_min.key.localized() + String(describing: data.minValue)
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    self.coordinator?.state.property.gatewayFee.asObservable().subscribe(onNext: { [weak self](fee) in
      guard let `self` = self else{ return }
      
      if let fee = fee, let asset = app_data.assetInfo[self.feeAssetId]{
        let feeAmount = getRealAmount(fee.asset_id, amount: fee.amount)
        if AssetConfiguration.CYB == self.feeAssetId {
          // 当前CYB作为手续费base
          if let balances = UserManager.shared.balances.value {
            for balance in balances{
              
              if balance.asset_type == AssetConfiguration.CYB{
                let cybAmount = getRealAmount(balance.asset_type, amount: balance.balance)
                if feeAmount <= cybAmount{
                  self.gateAwayFee.text = String(describing:feeAmount).formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade
                }else{
                  self.feeAssetId = (self.trade?.id)!
                  self.coordinator?.getGatewayFee((self.trade?.id)!, amount: self.amountView.content.text!, feeAssetID: self.feeAssetId, address: self.addressView.content.text!)
                }
                return
              }
            }
          }
        }else{
          // 当前提现的币作为手续费base
          if let balance = self.balance{
            let availableAmount = getRealAmount(balance.asset_type, amount: balance.balance)
            if let withdrawAmount = self.amountView.content.text?.toDouble(){
              if availableAmount < feeAmount + withdrawAmount{
                self.isAvalibaleAmount = false
                self.errorView.isHidden = false
                self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
              }else{
                self.isAvalibaleAmount = true
                self.finalAmount.text = String(withdrawAmount - feeAmount) + " " + (app_data.assetInfo[self.feeAssetId]?.symbol.filterJade)!
              }
            }
          }
        }
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
  }
}

extension RechargeDetailViewController{
  func changeWithdrawState(){
    if UserManager.shared.isLocked{
      print("解锁失败")
      self.checkLock()
    }else{
      if UserManager.shared.isWithDraw,self.isWithdraw,self.isTrueAddress,self.amountView.content.text != "",self.isAvalibaleAmount{
        self.withdraw.isEnable = true
        self.withdraw.button.isUserInteractionEnabled = true
        self.withdraw.button.isEnabled = true
        self.coordinator?.getGatewayFee((self.trade?.id)!, amount: self.amountView.content.text!, feeAssetID: self.feeAssetId, address: self.addressView.content.text!)
      }else{
        self.withdraw.isEnable = false
        self.withdraw.button.isUserInteractionEnabled = false
        self.withdraw.button.isEnabled = false
      }
    }
  }
  
  @objc func cleanAddress() {
    self.addressView.content.text = ""
  }
  
  @objc func addAllAmount(){
    if let balance = self.balance{
      if let fee = self.coordinator?.state.property.data.value?.fee{
        self.amountView.content.text = String(describing: getRealAmount(balance.asset_type, amount: balance.balance))
        if let name = app_data.assetInfo[balance.asset_type]?.symbol.filterJade{
          if let amount = self.amountView.content.text?.toDouble(){
            if fee > amount{
              self.finalAmount.text = "0 " + name
            }else{
              self.finalAmount.text = String(amount - fee) + " " + name
            }
          }
        }
      }else{
        self.amountView.content.text = String(describing: getRealAmount(balance.asset_type, amount: balance.balance))
        if let name = app_data.assetInfo[balance.asset_type]?.symbol.filterJade{
          self.finalAmount.text = self.amountView.content.text! + " " + name
        }
      }
    }
  }
  
  @objc func keyboardWillShow(){
    
    if self.addressView.content.isFirstResponder || self.amountView.content.isFirstResponder{
      self.feeView.subviews.forEach { (view) in
        view.isHidden = true
      }
      self.introduceView.subviews.forEach { (view) in
        view.isHidden = true
      }
      self.feeView.isHidden       = true
      self.introduceView.isHidden = true
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func keyboardWillHidden(){
    if self.addressView.content.isFirstResponder || self.amountView.content.isFirstResponder{
      
      self.feeView.subviews.forEach { (view) in
        view.isHidden = false
      }
      self.introduceView.subviews.forEach { (view) in
        view.isHidden = false
      }
      self.feeView.isHidden       = false
      self.introduceView.isHidden = false
      self.view.layoutIfNeeded()
    }
  }
  
  
  @objc func withDrawAction(){
    let _ = CommonStyles.init()
    let subView = StyleContentView(frame: .zero)
    ShowManager.shared.setUp(title: "CONFIERMATION", contentView: subView, animationType: .up_down)
    ShowManager.shared.showAnimationInView(self.view)
    ShowManager.shared.delegate = self
    
    subView.data = getWithdrawDetailInfo(addressInfo: self.addressView.content.text!, amountInfo: self.amountView.content.text! + " " + (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!, withdrawFeeInfo: self.insideFee.text!, gatewayFeeInfo: self.gateAwayFee.text!, receiveAmountInfo: self.finalAmount.text!)
  }
}

extension RechargeDetailViewController : ShowManagerDelegate{
  func returnUserPassword(_ sender : String){
    self.coordinator?.login(sender, callback: { [weak self](isAuthory) in
      guard let `self` = self else {return}
      if isAuthory {
        ShowManager.shared.hide()
        self.changeWithdrawState()
        if !UserManager.shared.isWithDraw{
          self.checkIsAuthory()
        }
      }else{
        
        ShowManager.shared.data = R.string.localizable.recharge_invalid_password.key.localized()
      }
    })
  }
  // 提现操作
  func returnEnsureAction(){
    
    let fee_amount = String((self.gateAwayFee.text?.split(separator: " ").first)!)
    self.coordinator?.getObjects(assetId: (self.trade?.id)!,amount: self.amountView.content.text!,address: self.addressView.content.text!,fee_id: self.feeAssetId,fee_amount: fee_amount,callback: { (data) in
      main {
        if String(describing: data) == "<null>"{
          ShowManager.shared.hide()
          
          ShowManager.shared.setUp(title_image: R.image.icCheckCircleGreen.name, message: R.string.localizable.recharge_withdraw_success.key.localized(), animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
          ShowManager.shared.showAnimationInView(self.view)
          ShowManager.shared.hide(1)
        }else{
          ShowManager.shared.hide()
          ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: R.string.localizable.recharge_withdraw_failed.key.localized(), animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
          ShowManager.shared.showAnimationInView(self.view)
          ShowManager.shared.hide(1)
        }
      }
    })
  }
}
