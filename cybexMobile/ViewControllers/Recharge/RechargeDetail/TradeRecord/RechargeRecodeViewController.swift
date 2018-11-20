//
//  RechargeRecodeViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class RechargeRecodeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var coordinator: (RechargeRecodeCoordinatorProtocol & RechargeRecodeStateManagerProtocol)?

    var assetInfo: AssetInfo? {
        didSet {
        }
    }
    var data: [Record] = [Record]()
    var isNoMoreData: Bool = false
    var recordType: FundType = .ALL {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupEvent()
        fetchRecords()
    }

    func fetchRecords() {
        self.coordinator?.fetchAssetUrl()
        if UserManager.shared.isLocked {
            self.showPasswordBox()
        } else {
            fetchDepositRecords(offset: 0) {}
        }
    }

    func setupUI() {
        if recordType == .ALL {
        } else {
            self.title = recordType == .DEPOSIT ? R.string.localizable.deposit_list.key.localized() : R.string.localizable.withdraw_list.key.localized()
        }
        let nibString = String(describing: RecodeCell.self)
        self.tableView.register(UINib(nibName: nibString, bundle: nil), forCellReuseIdentifier: nibString)
    }

    func setupEvent() {
        self.addPullToRefresh(self.tableView) {[weak self](completion) in
            guard let `self` = self else { return }
            if UserManager.shared.isLocked {
                self.showPasswordBox()
                completion?()
                return
            }
            self.fetchDepositRecords(offset: 0) {
                completion?()
            }
        }

        self.addInfiniteScrolling(self.tableView) { (completion) in
            if UserManager.shared.isLocked {
                self.showPasswordBox()
                completion?(false)
                return
            }
            if self.isNoMoreData {
                completion?(true)
                return
            }
            if let tradeRecords = self.coordinator?.state.data.value {
                self.fetchDepositRecords(offset: tradeRecords.offset + tradeRecords.size) {
                    completion?(self.isNoMoreData)
                }
            }
        }
    }

    func fetchDepositRecords(offset: Int = 0, callback:@escaping () -> Void) {
        self.startLoading()
        if let name = UserManager.shared.name.value {
            self.coordinator?.fetchRechargeRecodeList(name,
                                                      asset: self.assetInfo?.symbol ?? "",
                                                      fundType: recordType,
                                                      size: 20,
                                                      offset: offset,
                                                      expiration: Int(Date().timeIntervalSince1970 + 600),
                                                      assetId: self.assetInfo?.id ?? "",
                                                      callback: { [weak self] success in

                guard let `self` = self else {return}
                self.endLoading()
                if success, let tradeRecords = self.coordinator?.state.data.value, let records = tradeRecords.records {
                    if offset == 0 {
                        self.data.removeAll()
                    }
                    self.data += records
                    if self.data.count == 0 {
                        self.view.showNoData(R.string.localizable.recode_nodata.key.localized(), icon: R.image.img_no_records.name)
                        self.isNoMoreData = true
                        return
                    } else {
                        self.view.hiddenNoData()
                    }
                    if records.count < 20 {
                        self.isNoMoreData = true
                    }
                    if self.isVisible {
                        self.tableView.reloadData()
                    }
                }
                callback()
            })
        }
    }

    override func configureObserveState() {
    }
}

extension RechargeRecodeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellString = String(describing: RecodeCell.self)
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellString, for: indexPath) as? RecodeCell {
            cell.setup(self.data[indexPath.row], indexPath: indexPath)
            return cell
        }
        return RecodeCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let details = self.data[indexPath.row].details {
            var hash = ""
            for detail in details {
                if detail.hash.count != 0 {
                    hash = detail.hash
                    break
                }
            }
            self.coordinator?.openRecordDetailUrl(hash, asset: self.data[indexPath.row].asset.filterJade)
        }
    }
}

extension RechargeRecodeViewController {
    override func passwordDetecting() {
        self.startLoading()
    }

    override func passwordPassed(_ passed: Bool) {
        if passed {
            if self.data.count == 0 {
                fetchDepositRecords(offset: 0) {}
            } else {
                if let tradeRecords = self.coordinator?.state.data.value {
                    if self.isNoMoreData {
                        return
                    }
                    fetchDepositRecords(offset: tradeRecords.offset + tradeRecords.size) {}
                }
            }
        } else {
            self.endLoading()
            if self.isVisible {
                self.showToastBox(false, message: R.string.localizable.recharge_invalid_password.key.localized())
            }
        }
    }
}
