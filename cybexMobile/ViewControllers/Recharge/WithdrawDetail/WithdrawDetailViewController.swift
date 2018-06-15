//
//  WithdrawDetailViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class WithdrawDetailViewController: BaseViewController {

    @IBOutlet weak var icon: UIImageView!
    
    var coordinator: (WithdrawDetailCoordinatorProtocol & WithdrawDetailStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveIcon(_ sender: Any) {
        
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        
    }
    
    @IBAction func resetAddress(_ sender: Any) {
        
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
