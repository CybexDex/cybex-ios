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
import SwiftNotificationCenter

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.coordinator?.refreshData(nil)
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
        
        self.coordinator?.state.property.data.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let `self` = self else { return }
            
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil , onDisposed: nil).disposed(by: disposeBag)
    }
}

extension WithdrawAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coordinator?.state.property.data.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.withdrawAddressTableViewCell.name, for: indexPath) as! WithdrawAddressTableViewCell
        
        if let data = self.coordinator?.state.property.data.value {
            cell.setup(data[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

