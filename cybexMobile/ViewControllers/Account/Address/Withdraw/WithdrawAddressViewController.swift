//
//  WithdrawAddressViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class WithdrawAddressViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

	var coordinator: (WithdrawAddressCoordinatorProtocol & WithdrawAddressStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        configRightNavButton(R.image.ic_add_24_px())
        self.tableView.register(R.nib.withdrawAddressTableViewCell(), forCellReuseIdentifier: R.nib.withdrawAddressTableViewCell.name)
    }
    
    override func rightAction(_ sender: UIButton) {
        
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

extension WithdrawAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.withdrawAddressTableViewCell.name, for: indexPath) as! WithdrawAddressTableViewCell
        
        return cell
    }
}

