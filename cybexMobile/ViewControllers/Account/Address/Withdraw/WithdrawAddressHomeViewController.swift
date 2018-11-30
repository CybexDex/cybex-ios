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
        self.localizedText = R.string.localizable.withdraw_address_manager.key.localizedContainer()

        self.tableView.register(UINib(resource: R.nib.withdrawAddressHomeTableViewCell),
                                forCellReuseIdentifier: R.nib.withdrawAddressHomeTableViewCell.name)
    }

    override func configureObserveState() {

        self.coordinator?.state.data.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let `self` = self, data.count > 0 else { return }

            self.coordinator?.fetchAddressData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.coordinator?.state.addressData.asObservable().subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            self.endLoading()
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension WithdrawAddressHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coordinator?.state.data.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.withdrawAddressHomeTableViewCell.name, for: indexPath) as? WithdrawAddressHomeTableViewCell else {
            return WithdrawAddressHomeTableViewCell()
        }

        if let data = self.coordinator?.state.data.value {
            cell.setup(data[indexPath.row], indexPath: indexPath)

            return cell
        }
        return WithdrawAddressHomeTableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.coordinator?.selectCell(indexPath.row)
        self.coordinator?.openWithDrawAddressVC()
    }
}
