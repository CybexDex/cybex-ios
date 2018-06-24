//
//  ExchangeViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class ExchangeViewController: BaseViewController {
  
  var coordinator: (ExchangeCoordinatorProtocol & ExchangeStateManagerProtocol)?
  var type : exchangeType = .buy

  var pair: Pair? {
    didSet{
      self.childViewControllers.forEach { (viewController) in
        if var viewController = viewController as? TradePair{
          viewController.pariInfo = pair!
        }
      }
    }
  }
  
  @IBOutlet weak var containerView: ExchangeView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.coordinator?.setupChildVC(self) 
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
    
  }
}

extension ExchangeViewController : TradePair {
  var pariInfo: Pair {
    get {
      return self.pair!
    }
    set {
      self.pair = newValue
    }
  }
}

