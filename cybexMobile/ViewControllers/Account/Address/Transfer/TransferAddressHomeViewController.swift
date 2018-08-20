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
        configLeftNavButton(nil)
        configRightNavButton(R.image.ic_add_24_px())
        
        self.localized_text = R.string.localizable.transfer_account_manager.key.localizedContainer()

        self.tableView.register(R.nib.transferAddressHomeTableViewCell(), forCellReuseIdentifier: R.nib.transferAddressHomeTableViewCell.name)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.coordinator?.refreshData()
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openAddTransferAddress()
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
            
            if data.count == 0 {
                self.view.showNoData(R.string.localizable.account_transfer_nodata.key.localized(), icon: R.image.img_no_address.name)
            }
            else {
                self.view.hiddenNoData()
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil , onDisposed: nil).disposed(by: disposeBag)
    }
}

extension TransferAddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coordinator?.state.property.data.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.transferAddressHomeTableViewCell.name, for: indexPath) as! TransferAddressHomeTableViewCell
        if let data = self.coordinator?.state.property.data.value {
            cell.setup(data[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension TransferAddressHomeViewController {
    @objc func AddressCellViewDidClicked(_ data:[String: Any]) {
        if let addressdata = data["data"] as? TransferAddress {
            self.coordinator?.select(addressdata)
            self.coordinator?.openActionVC()
        }
    }
    
    override func returnEnsureAction() {
        self.coordinator?.delete()
        
        self.coordinator?.refreshData()
    }
}
