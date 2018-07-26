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
  
  @IBOutlet weak var pickerView: PickerView!
  
  var items: AnyObject?
  
  var selectedValue: (component: NSInteger,row: NSInteger) = (0,0)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    self.configRightNavButton(R.string.localizable.picker_comfirm.key.decapitalized())
    if let items = items {
      pickerView.items = items
      pickerView.selectRow(selectedValue.component, inComponent: selectedValue.row)
    }
  }
  
  override func rightAction(_ sender: UIButton) {
    self.coordinator?.dismiss()
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
