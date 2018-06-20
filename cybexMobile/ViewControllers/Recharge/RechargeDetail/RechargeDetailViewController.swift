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
    self.coordinator?.fetchWithDrawInfoData("ETH")
  }
  
  func setupUI(){
    avaliableView.content.text = changeToETHAndCYB((balance?.asset_type)!).eth + " ETH"
  
  }
  
  func setupEvent(){
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidBeginEditing, object: amountView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{ return }
      self.feeView.isHidden = true
      self.introduceView.isHidden = true
    }
    
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidEndEditing, object: amountView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{ return }
      self.feeView.isHidden = false
      self.introduceView.isHidden = false
    }
    
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidBeginEditing, object: addressView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{ return }
      self.feeView.isHidden = true
      self.introduceView.isHidden = true
    }
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidEndEditing, object: addressView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{ return }
      self.feeView.isHidden = true
      self.introduceView.isHidden = true
    }
    
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidChange, object: amountView.content, queue: nil) { [weak self](notification) in
      guard let `self` = self else{return}
      if let amount = self.amountView.content.text?.toDouble(){
        let avaliable = changeToETHAndCYB((self.balance?.asset_type)!).eth.toDouble()!
        if amount > avaliable{
          self.errorView.isHidden = false
          self.errorL.locali =  R.string.localizable.withdraw_nomore.key.localized()
        }else{
          self.errorView.isHidden = true
        }
      }
    }
    
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidChange, object: addressView.content, queue: nil) { [weak self] (notification) in
      guard let `self` = self else{return}
      
//      do{
//        let data = try await(GraphQLManager.shared.verifyAddress(assetName: (app_data.assetInfo[(self.balance?.asset_type)!]?.symbol.filterJade)!, address: self.addressView.content.text!))
//
//        if let data = data{
//          if data.valid{
//            self.errorView.isHidden = true
//          }else{
//            self.errorView.isHidden = false
//            self.errorL.locali =  R.string.localizable.withdraw_address.key.localized()
//          }
//        }
//      }catch{
//        self.errorView.isHidden = false
//        self.errorL.locali =  R.string.localizable.withdraw_address.key.localized()
//      }
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
        
//          self.amountView.content.placeholder = Localize.currentLanguage() == "en" ? "Min" + String(describing: data.minValue) : "最小提现数量 " + String(describing: data.minValue)
      }
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
}
