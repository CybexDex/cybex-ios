//
//  AddAddressViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class AddAddressViewController: BaseViewController {

    @IBOutlet weak var containerView: AddAddressView!
    var coordinator: (AddAddressCoordinatorProtocol & AddAddressStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
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
        
        (self.containerView.asset.content.rx.text.orEmpty <-> self.coordinator!.state.property.asset).disposed(by: disposeBag)
        (self.containerView.address.content.rx.text.orEmpty <-> self.coordinator!.state.property.address).disposed(by: disposeBag)
        (self.containerView.mark.content.rx.text.orEmpty <-> self.coordinator!.state.property.note).disposed(by: disposeBag)
        (self.containerView.memo.content.rx.text.orEmpty <-> self.coordinator!.state.property.memo).disposed(by: disposeBag)
        
        
    }
    
    override func configureObserveState() {
        commonObserveState()
        
    }
}
