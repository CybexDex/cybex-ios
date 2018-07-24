//
//  PickerViewController.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class PickerViewController: BaseViewController {
  
  var coordinator: (PickerCoordinatorProtocol & PickerStateManagerProtocol)?
  
  @IBOutlet weak var picker: UIPickerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func setupUI() {
    
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
