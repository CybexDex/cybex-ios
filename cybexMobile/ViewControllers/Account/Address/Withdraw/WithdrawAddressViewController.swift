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
import NBLCommonModule

class WithdrawAddressViewController: BaseViewController {
    var asset : String = ""
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var rightLabel: UILabel!
    
    @IBOutlet weak var leftLabel: UILabel!
    var coordinator: (WithdrawAddressCoordinatorProtocol & WithdrawAddressStateManagerProtocol)?

	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        configRightNavButton(R.image.ic_add_24_px())
        self.rightLabel.isHidden = !self.coordinator!.isEOS()
        if let asset_info = app_data.assetInfo[self.asset] {
            if self.coordinator!.isEOS() {
                self.title = asset_info.symbol.filterJade + " " + R.string.localizable.eos_withdraw_account.key.localized()
            }
            else {
                self.title = asset_info.symbol.filterJade + " " + R.string.localizable.withdraw_address.key.localized()
            }
        }
        else {
            self.localized_text = self.coordinator!.isEOS() ? R.string.localizable.eos_withdraw_account.key.localizedContainer() : R.string.localizable.withdraw_address.key.localizedContainer()
        }
        if !self.coordinator!.isEOS() {
            self.leftLabel.locali = R.string.localizable.account_or_address.key
        }
        self.tableView.register(R.nib.withdrawAddressTableViewCell(), forCellReuseIdentifier: R.nib.withdrawAddressTableViewCell.name)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.coordinator?.refreshData()
    }
    
    override func rightAction(_ sender: UIButton) {
       self.coordinator?.openAddWithdrawAddress()
    }
    
    override func configureObserveState() {        
        self.coordinator?.state.property.data.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let `self` = self else { return }
            
            if data.count == 0 {
                self.view.showNoData(self.coordinator!.isEOS() ? R.string.localizable.account_nodata.key.localized() : R.string.localizable.address_nodata.key.localized(), icon: R.image.img_no_address.name)
            }
            else {
                self.view.hiddenNoData()
            }
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

extension WithdrawAddressViewController {
    @objc func AddressCellViewDidClicked(_ data:[String: Any]) {
        if let addressdata = data["data"] as? WithdrawAddress, let view = data["self"] as? AddressCellView {
            self.coordinator?.select(addressdata)
            
            view.isSelected = true
            self.coordinator?.openActionVC({
                view.isSelected = false
            })
        }
    }
    
    override func returnEnsureAction() {
        self.coordinator?.delete()
        
        self.coordinator?.refreshData()
    }
}

