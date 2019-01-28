//
//  TransferListViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class TransferListViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!

    var coordinator: (TransferListCoordinatorProtocol & TransferListStateManagerProtocol)?
    var data: [TransferRecordViewModel]?

    var page: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        self.startLoading()

        self.coordinator?.fetchTransferRecords(page, callback: nil)
    }

    func setupUI() {
        self.title = R.string.localizable.transfer_list_title.key.localized()
        let nibString = String(describing: TransferListCell.self)
        self.tableView.register(UINib(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
    }

    func setupTableView() {
        self.addPullToRefresh(self.tableView) {[weak self] (completion) in
            guard let self = self else { return }

            self.page = 0
            self.coordinator?.fetchTransferRecords(self.page, callback: { noMoreData in
                completion?()
            })
        }

        self.addInfiniteScrolling(self.tableView) {[weak self] (completion) in
            guard let self = self else { return }

            if self.view.noDataView != nil {
                completion?(true)
                return
            }

            self.page += 1
            self.coordinator?.fetchTransferRecords(self.page, callback: { noMoreData in
                completion?(noMoreData)
            })
        }
    }

    override func configureObserveState() {
        self.coordinator?.state.data.asObservable().subscribe(onNext: { [weak self](data) in
            guard let self = self else { return }
            self.endLoading()
            if self.isVisible {
                if self.page == 0 {
                    self.data = data
                }
                else {
                    guard let d = data else { return }
                    self.data?.append(contentsOf: d)
                }

                if self.data?.count == 0 && self.page == 0 {
                    self.view.showNoData(R.string.localizable.recode_nodata.key.localized(), icon: R.image.img_no_records.name)
                    return
                } else {
                    self.view.hiddenNoData()
                }
                self.tableView.reloadData()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension TransferListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.data {
            return data.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellString = String(describing: TransferListCell.self)
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellString, for: indexPath) as? TransferListCell {
            cell.setup(self.data![indexPath.row], indexPath: indexPath)
            return cell
        }
        return TransferListCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = self.data {
            self.coordinator?.openTransferDetail(data[indexPath.row])
        }
    }

}
