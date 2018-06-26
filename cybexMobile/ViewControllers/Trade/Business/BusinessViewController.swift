//
//  BusinessViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class BusinessViewController: BaseViewController {
  var pair: Pair? {
    didSet{
      self.coordinator?.resetState()
      guard let base_info = app_data.assetInfo[pair!.base], let quote_info = app_data.assetInfo[pair!.quote] else { return }
      self.coordinator?.getFee(self.type == .buy ? base_info.id : quote_info.id)

      self.containerView.quoteName.text = quote_info.symbol.filterJade
      
      self.coordinator?.getBalance((self.type == .buy ? base_info.id : quote_info.id))
      
      self.containerView.button.locali = self.type == .buy ? R.string.localizable.openedBuy.key.localized() : R.string.localizable.openedSell.key.localized()
      if let title = self.containerView.button.button.titleLabel?.text {
        self.containerView.button.locali = "\(title) \(quote_info.symbol.filterJade)"

      }
    }
  }
  
  @IBOutlet weak var containerView: BusinessView!

  var type : exchangeType = .buy
  
  var coordinator: (BusinessCoordinatorProtocol & BusinessStateManagerProtocol)?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
   
  }
  
  func setupUI(){
    containerView.button.gradientLayer.colors = type == .buy ? [UIColor.paleOliveGreen.cgColor,UIColor.apple.cgColor] : [UIColor.pastelRed.cgColor,UIColor.reddish.cgColor]
  }
  
  func showEnterPassword(){
    let title = R.string.localizable.withdraw_unlock_wallet.key.localized()
    ShowManager.shared.setUp(title: title, contentView: CybexPasswordView(frame: .zero), animationType: .up_down)
    ShowManager.shared.delegate = self
    ShowManager.shared.showAnimationInView(self.view)
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

    (self.containerView.amountTextfield.rx.text.orEmpty <-> self.coordinator!.state.property.amount).disposed(by: disposeBag)
    (self.containerView.priceTextfield.rx.text.orEmpty <-> self.coordinator!.state.property.price).disposed(by: disposeBag)
    
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidEndEditing, object: self.containerView.priceTextfield, queue: nil) {[weak self] (notifi) in
      guard let `self` = self else { return }
      guard let text = self.containerView.priceTextfield.text, text != "", text.toDouble() != 0 else {
        self.containerView.priceTextfield.text = ""
        return
      }
      self.containerView.priceTextfield.text = text.tradePrice.price
    }
    
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidEndEditing, object: self.containerView.amountTextfield, queue: nil) {[weak self] (notifi) in
      guard let `self` = self else { return }
      guard let text = self.containerView.amountTextfield.text, text != "", text.toDouble() != 0 else {
        self.containerView.amountTextfield.text = ""
        return
      }
      self.containerView.amountTextfield.text = text.tradePrice.price
    }
   
    
//balance
    self.coordinator?.state.property.balance.asObservable().subscribe(onNext: {[weak self] (balance) in
      guard let `self` = self else { return }

      guard let pair = self.pair, let base_info = app_data.assetInfo[pair.base], let quote_info = app_data.assetInfo[pair.quote], balance != 0 else {
        self.containerView.balance.text = "--"
        return
        
      }
      
      let info = self.type == .buy ? base_info : quote_info
      let symbol = info.symbol.filterJade
      let realAmount = balance.string(digits: info.precision)
      
      self.containerView.balance.text = "\(realAmount) \(symbol)"
      
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
//fee
    Observable.combineLatest(coordinator!.state.property.feeID.asObservable(), coordinator!.state.property.fee_amount.asObservable()).subscribe(onNext: {[weak self] (fee_id, fee_amount) in
      guard let `self` = self else { return }

      guard let info = app_data.assetInfo[fee_id] else {
        self.containerView.fee.text = "--"
        return
      }
      self.containerView.fee.text = "\(fee_amount) \(info.symbol.filterJade)"

    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    

//total
    Observable.combineLatest(coordinator!.state.property.feeID.asObservable(), self.coordinator!.state.property.amount, self.coordinator!.state.property.price, coordinator!.state.property.fee_amount.asObservable()).subscribe(onNext: {[weak self] (feeID, amount, price, fee) in
      guard let `self` = self else { return }
      guard let pair = self.pair, let base_info = app_data.assetInfo[pair.base] else {
        self.containerView.endMoney.text = "--"
        return
      }

      guard let limit = price.toDouble(), let amount = amount.toDouble(), limit != 0, amount != 0, fee != 0 else {
        self.containerView.endMoney.text = "--"
        return
      }

      let total = limit * amount
      
      self.containerView.endMoney.text = "\(total.tradePrice().price) \(base_info.symbol.filterJade)"
      
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    
  }
}

extension BusinessViewController : TradePair {
  var pariInfo: Pair {
    get {
      return self.pair!
    }
    set {
      self.pair = newValue
    }
  }
}

extension BusinessViewController {
  @objc func amountPercent(_ data:[String:Any]) {
    if let percent = data["percent"] as? String {
      guard let pair = self.pair, let base_info = app_data.assetInfo[pair.base], let quote_info = app_data.assetInfo[pair.quote]  else { return }
      self.coordinator?.changePercent(percent.toDouble()! / 100.0, isBuy: self.type == .buy, assetID: self.type == .buy ? base_info.id : quote_info.id)
    }
  }
  
  @objc func buttonDidClicked(_ data: [String: Any]) {
    guard let _ = self.pair else { return }

    if UserManager.shared.isLocked {
      showEnterPassword()
    }
    else {
      postOrder()
    }
  }
  
  func postOrder() {
    guard let pair = self.pair else { return }

    self.startLoading()
    self.coordinator?.postLimitOrder(pair, isBuy: self.type == .buy, callback: {[weak self] (success) in
      guard let `self` = self else { return }
      
      self.endLoading()
      ShowManager.shared.setUp(title_image: success ? R.image.icCheckCircleGreen.name : R.image.erro16Px.name, message: success ? R.string.localizable.order_create_success() : R.string.localizable.order_create_fail(), animationType: .up_down, showType: .alert_image)
      ShowManager.shared.showAnimationInView(self.view)
      ShowManager.shared.hide(2)
    })
  }
  
  @objc func adjustPrice(_ data:[String : Bool]) {
    self.coordinator?.adjustPrice(data["plus"]!)
  }
}

extension BusinessViewController : ShowManagerDelegate{
  func returnEnsureAction() {
    
  }
  
  func returnUserPassword(_ sender : String){
    if let name = UserManager.shared.name {
      UserManager.shared.unlock(name, password: sender) { (success, _) in
        if success {
          ShowManager.shared.hide()
          self.postOrder()
        }
        else {
          
        }
       
      }
    }
  }
}
