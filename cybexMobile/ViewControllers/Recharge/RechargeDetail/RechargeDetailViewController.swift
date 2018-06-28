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
import Guitar

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
    if let name = app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade{
      self.coordinator?.fetchWithDrawMessage(callback: { (message) in

        self.introduce.attributedText = message.replacingOccurrences(of: "$asset", with: name).set(style: StyleNames.introduce_normal.rawValue)
      })
    }
   
    amountView.content.keyboardType = .decimalPad
    addressView.btn.isHidden        = true
    amountView.btn.setTitle(R.string.localizable.openedAll.key.localized(), for: .normal)
    if let balance = self.balance{
      if let precision = app_data.assetInfo[balance.asset_type]?.precision{
        avaliableView.content.text = String(describing: getRealAmount(balance.asset_type, amount: balance.balance)).formatCurrency(digitNum: (precision)) + " " + (app_data.assetInfo[balance.asset_type]?.symbol.filterJade)!
      }
    }else{
      avaliableView.content.text = "--" + (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!
    }
    self.withdraw.isEnable = false
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
      self.showPassWord()
      return
    }
    if !UserManager.shared.isWithDraw{
      self.checkIsAuthory()
      return
    }
  }
  
  func checkIsWithdraw(){
      var message = ""
      if let enMsg = self.trade?.enMsg,let cnMsg = self.trade?.cnMsg{
        if Localize.currentLanguage() == "en"{
          message = enMsg
        }else{
          message = cnMsg
        }
      }
      ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: message, animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
  }
  
  func showPassWord(){
    let title = R.string.localizable.withdraw_unlock_wallet.key.localized()
    ShowManager.shared.setUp(title: title, contentView: CybexPasswordView(frame: .zero), animationType: .up_down)
    ShowManager.shared.delegate = self
    ShowManager.shared.showAnimationInView(self.view)
    
  }
  
  func checkIsAuthory(){
    let message = R.string.localizable.withdraw_miss_authority.key.localized()
    ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: message, animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
    ShowManager.shared.showAnimationInView(self.view)
    ShowManager.shared.hide(2)
    
  }
  
  
  func setupEvent(){
    self.withdraw.button.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: amountView.content, queue: nil) { [weak self](notification) in
      guard let `self` = self else {return}
      if let text = self.amountView.content.text,let amount = text.toDouble(),amount > 0{
        if let balance = self.balance{
          if let priction = app_data.assetInfo[balance.asset_type]?.precision{
            if text.contains("."){
              let texts = text.split(separator: ".")
              if (texts.last?.count)! > priction {
                self.amountView.content.text = String(texts.first!) + "." + String(texts.last!).substring(from: 0, length: priction)!
              }
            }
          }
         
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
              if let asset = app_data.assetInfo[balance.asset_type]{
                self.finalAmount.text = String(amount - data.fee).formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade
              }
            }
          }
        }
      }
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: addressView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{return}
      
      if let address = self.addressView.content.text , address.count > 0 {
        self.addressView.btn.isHidden = false
        let letterBegin = Guitar(pattern: "^([a-zA-Z0-9])")
        if !letterBegin.test(string: address){
          self.isTrueAddress = false
          self.errorView.isHidden = false
          self.errorL.locali =  R.string.localizable.withdraw_address_fault.key.localized()
          return
        }
        if let balance = self.balance{
          if let assetName = app_data.assetInfo[balance.asset_type]?.symbol.filterJade{
            self.coordinator?.verifyAddress(assetName, address: address, callback: { (success) in
              if success{
                self.isTrueAddress      = true
                self.errorView.isHidden = true
              }else{
                self.isTrueAddress = false
                self.errorView.isHidden = false
                self.errorL.locali =  R.string.localizable.withdraw_address_fault.key.localized()
              }
            })
          }
        }
      }else{
        self.addressView.btn.isHidden = true
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
        if let precision = app_data.assetInfo[(self.trade?.id)!]?.precision{
          self.insideFee.text = String(describing: data.fee).formatCurrency(digitNum: precision) + " " + (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!
        }
        
        self.amountView.textplaceholder = R.string.localizable.recharge_min.key.localized() + String(describing: data.minValue)
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    self.coordinator?.state.property.gatewayFee.asObservable().subscribe(onNext: { [weak self](fee) in
      guard let `self` = self else{ return }
      
      if let fee = fee, let asset = app_data.assetInfo[self.feeAssetId]{
        let feeAmount = getRealAmount(fee.asset_id, amount: fee.amount)
        if AssetConfiguration.CYB == self.feeAssetId {
          // 当前CYB作为手续费币种
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
          // 当前提现的币作为手续费币种
          if let balance = self.balance{
            let availableAmount = getRealAmount(balance.asset_type, amount: balance.balance)
            if let withdrawAmount = self.amountView.content.text?.toDouble(){
              if availableAmount < feeAmount + withdrawAmount{
                self.isAvalibaleAmount = false
                self.errorView.isHidden = false
                self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
              }else{
                self.gateAwayFee.text = String(describing:feeAmount).formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade

                if let withdrawFee = self.insideFee.text?.toDouble(){
                  if availableAmount < feeAmount + withdrawAmount + withdrawFee{
                    self.isAvalibaleAmount = false
                    self.errorView.isHidden = false
                    self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
                    return
                  }
                  self.isAvalibaleAmount = true
                  let priction = asset.precision
                  self.finalAmount.text = String(withdrawAmount - feeAmount - withdrawFee).formatCurrency(digitNum: priction) + " " + (app_data.assetInfo[self.feeAssetId]?.symbol.filterJade)!
                }
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
    if self.trade?.enable == false{
      return
    }
    if UserManager.shared.isLocked{
      print("解锁失败")
      self.showPassWord()
    }else{
      if UserManager.shared.isWithDraw,self.isWithdraw,self.isTrueAddress,self.amountView.content.text != "",self.isAvalibaleAmount{
        self.withdraw.isEnable = true
        self.withdraw.button.isEnabled = true
        self.coordinator?.getGatewayFee((self.trade?.id)!, amount: self.amountView.content.text!, feeAssetID: self.feeAssetId, address: self.addressView.content.text!)
      }else{
        self.withdraw.isEnable = false
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
        if let asset = app_data.assetInfo[balance.asset_type]{
          if let amount = self.amountView.content.text?.toDouble(){
            if fee > amount{
              self.finalAmount.text = "-" + asset.symbol.filterJade
            }else{
              self.finalAmount.text = String(amount - fee).formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade
            }
          }
        }
      }else{
        self.amountView.content.text = String(describing: getRealAmount(balance.asset_type, amount: balance.balance))
        if let asset = app_data.assetInfo[balance.asset_type],let amountText = self.amountView.content.text{
          self.finalAmount.text = amountText.formatCurrency(digitNum: asset.precision) + " " + asset.symbol.filterJade
        }
      }
    }
  }
  
  @objc func keyboardWillShow(){
    
    if self.addressView.content.isFirstResponder || self.amountView.content.isFirstResponder{
    
      self.feeView.isHidden       = true
      self.introduceView.isHidden = true
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func keyboardWillHidden(){
    if self.addressView.content.isFirstResponder || self.amountView.content.isFirstResponder{
      
      self.feeView.isHidden       = false
      self.introduceView.isHidden = false
      self.view.layoutIfNeeded()
    }
  }
  
  
  @objc func withDrawAction(){
    let subView = StyleContentView(frame: .zero)
    
    ShowManager.shared.setUp(title: R.string.localizable.withdraw_ensure_title.key.localized(), contentView: subView, animationType: .up_down)
    ShowManager.shared.showAnimationInView(self.view)
    ShowManager.shared.delegate = self
    
    if let addressText = self.addressView.content.text,let amountText = self.amountView.content.text,let insideText = self.insideFee.text,let gatewayFeeText = self.gateAwayFee.text,let finalAmountText = self.finalAmount.text{
      subView.data = getWithdrawDetailInfo(addressInfo: addressText, amountInfo: amountText + " " + (app_data.assetInfo[(self.trade?.id)!]?.symbol.filterJade)!, withdrawFeeInfo: insideText, gatewayFeeInfo: gatewayFeeText, receiveAmountInfo: finalAmountText)
    }
  }
}

extension RechargeDetailViewController : ShowManagerDelegate{
  func returnUserPassword(_ sender : String){
    startLoading()
    self.coordinator?.login(sender, callback: { [weak self](isAuthory) in
      guard let `self` = self else {return}
      self.endLoading()
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
        ShowManager.shared.hide()
        if String(describing: data) == "<null>"{
          ShowManager.shared.setUp(title_image: R.image.icCheckCircleGreen.name, message: R.string.localizable.recharge_withdraw_success.key.localized(), animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
          ShowManager.shared.showAnimationInView(self.view)
          ShowManager.shared.hide(2)
        }else{
          ShowManager.shared.setUp(title_image: R.image.erro16Px.name, message: R.string.localizable.recharge_withdraw_failed.key.localized(), animationType: ShowManager.ShowAnimationType.fadeIn_Out, showType: ShowManager.ShowManagerType.alert_image)
          ShowManager.shared.showAnimationInView(self.view)
          ShowManager.shared.hide(2)
        }
      }
    })
  }
}
