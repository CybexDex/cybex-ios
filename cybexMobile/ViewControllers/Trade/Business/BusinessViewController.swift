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
  var data : Any? {
    didSet{
      
    }
  }
  var pair: Pair?{
    didSet{
      
    }
  }
  @IBOutlet weak var button: Button!
  @IBOutlet weak var errorMessage: UILabel!
  @IBOutlet weak var balance: UILabel!
  
  @IBOutlet weak var service: UILabel!
  @IBOutlet weak var endMoney: UILabel!
  
  enum VC_TYPE:String{
    case BUY
    case SELL
  }
  
  var vc_type : VC_TYPE = VC_TYPE.BUY
  var coordinator: (BusinessCoordinatorProtocol & BusinessStateManagerProtocol)?
  
  @IBAction func changePrice(_ sender: UIButton) {
    if sender.tag == 1001{
      // -
      
    }else{
      // +
      
    }
  }
  
  override func loadView() {
    super.loadView()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  func setupUI(){
    button.gradientLayer.colors = vc_type.rawValue == "BUY" ? [UIColor.paleOliveGreen.cgColor,UIColor.apple.cgColor] : [UIColor.pastelRed.cgColor,UIColor.reddish.cgColor]
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
