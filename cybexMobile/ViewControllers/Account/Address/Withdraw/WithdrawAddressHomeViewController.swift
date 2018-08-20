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
        startLoading()
        self.coordinator?.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.coordinator?.fetchAddressData()
    }
    
    func setupUI() {
        self.localized_text = R.string.localizable.withdraw_address.key.localizedContainer()

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
        
        self.coordinator?.state.property.data.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let `self` = self, data.count > 0 else { return }
            
            self.coordinator?.fetchAddressData()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.property.addressData.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let `self` = self else { return }
            self.endLoading()
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension WithdrawAddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coordinator?.state.property.data.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.withdrawAddressHomeTableViewCell.name, for: indexPath) as! WithdrawAddressHomeTableViewCell
        
        if let data = self.coordinator?.state.property.data.value {
            cell.setup(data[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.coordinator?.selectCell(indexPath.row)
        self.coordinator?.openWithDrawAddressVC()
    }
}

