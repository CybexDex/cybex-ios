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

      let total = limit * amount + (feeID == base_info.id ? fee : 0)
      
      self.containerView.endMoney.text = "\(total.string(digits: base_info.precision)) \(base_info.symbol.filterJade)"
      
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
      self.coordinator?.changePercent(percent.toDouble()! / 100.0, isBuy: self.type == .buy, assetID: self.type == .buy ? base_info.id : quote_info.id, precision:quote_info.precision)
    }
  }
  
  @objc func buttonDidClicked(_ data: [String: Any]) {
    
  }
  
  @objc func adjustPrice(_ data:[String : Bool]) {
    guard let pair = self.pair, let base_info = app_data.assetInfo[pair.base], let _ = app_data.assetInfo[pair.quote]  else { return }

    self.coordinator?.adjustPrice(data["plus"]!, precision: base_info.precision)
  }
}

