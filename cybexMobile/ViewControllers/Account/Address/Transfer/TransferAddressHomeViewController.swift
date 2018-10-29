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

        self.localizedText = R.string.localizable.transfer_account_manager.key.localizedContainer()

        self.tableView.register(UINib(resource: R.nib.transferAddressHomeTableViewCell), forCellReuseIdentifier: R.nib.transferAddressHomeTableViewCell.name)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.coordinator?.refreshData()
    }

    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openAddTransferAddress()
    }

    override func configureObserveState() {
        self.coordinator?.state.property.data.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let `self` = self else { return }

            if data.count == 0 {
                self.view.showNoData(R.string.localizable.account_transfer_nodata.key.localized(), icon: R.image.img_no_address.name)
            } else {
                self.view.hiddenNoData()
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension TransferAddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coordinator?.state.property.data.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.transferAddressHomeTableViewCell.name, for: indexPath) as? TransferAddressHomeTableViewCell else {
            return TransferAddressHomeTableViewCell()
        }
        if let data = self.coordinator?.state.property.data.value {
            cell.setup(data[indexPath.row], indexPath: indexPath)
            return cell
        }
        return TransferAddressHomeTableViewCell()
    }
}

extension TransferAddressHomeViewController {
    @objc func addressCellViewDidClicked(_ data: [String: Any]) {
        if let addressdata = data["data"] as? TransferAddress, let view = data["self"] as? AddressCellView {
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
