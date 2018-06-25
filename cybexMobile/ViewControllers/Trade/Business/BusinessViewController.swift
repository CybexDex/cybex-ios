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
      guard let base_info = app_data.assetInfo[pair!.base], let quote_info = app_data.assetInfo[pair!.quote] else { return }

      self.containerView.baseName.text = base_info.symbol.filterJade
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
    
    coordinator?.state.property.price.asObservable()
      .skip(1)
      .distinctUntilChanged()
      .subscribe(onNext: { (s) in
       self.containerView.priceTextfield.text = s
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
      
    }
  }
}

