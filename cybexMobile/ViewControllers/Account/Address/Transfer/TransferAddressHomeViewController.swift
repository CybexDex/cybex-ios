//
//  TransferAddressHomeViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class TransferAddressHomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

	var coordinator: (TransferAddressHomeCoordinatorProtocol & TransferAddressHomeStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        configRightNavButton(R.image.ic_add_24_px())
        self.tableView.register(R.nib.transferAddressHomeTableViewCell(), forCellReuseIdentifier: R.nib.transferAddressHomeTableViewCell.name)
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

extension TransferAddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.transferAddressHomeTableViewCell.name, for: indexPath) as! TransferAddressHomeTableViewCell
        
        return cell
    }
}
