//
//  WithdrawAddressHomeViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class WithdrawAddressHomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

	var coordinator: (WithdrawAddressHomeCoordinatorProtocol & WithdrawAddressHomeStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        self.tableView.register(R.nib.withdrawAddressHomeTableViewCell(), forCellReuseIdentifier: R.nib.withdrawAddressHomeTableViewCell.name)
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

extension WithdrawAddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.withdrawAddressHomeTableViewCell.name, for: indexPath) as! WithdrawAddressHomeTableViewCell
        
        return cell
    }

}


extension WithdrawAddressHomeViewController {
    @objc func clickCellView(_ data:[String:Any]) {
        if let index = data["index"] as? Int {
            switch index {
            case 0:
                self.coordinator?.openWithDrawAddressVC()
            default:
                break
            }
        }
    }
}
