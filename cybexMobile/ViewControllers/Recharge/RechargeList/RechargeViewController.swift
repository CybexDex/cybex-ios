//
//  RechargeViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class RechargeViewController: BaseViewController {
    
    enum CellType: Int {
        case RECHARGE
        case WITHDRAW
    }
    var selectedIndex: CellType = .RECHARGE
    
    @IBOutlet weak var rechargeSegmentView: RechargeSegment!
    @IBOutlet weak var tableView: UITableView!
    var coordinator: (RechargeCoordinatorProtocol & RechargeStateManagerProtocol)?
    
    var depositData: [Trade]?
    var withdrawData: [Trade]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLoading()
        self.coordinator?.fetchDepositIdsInfo()
        self.coordinator?.fetchWithdrawIdsInfo()
        setupUI()
    }
    
    func setupUI() {
        self.localizedText = R.string.localizable.account_trade.key.localizedContainer()
        let cell = R.nib.tradeCell.name
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
        tableView.tableFooterView = UIView()
        rechargeSegmentView.segmentControl.selectedSegmentIndex = selectedIndex.rawValue
        configRightNavButton(R.image.ic_w_drecords())
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openRecordList()
    }
    
    override func configureObserveState() {
        
        self.coordinator?.state.depositIds.asObservable().skip(1).subscribe(onNext: { [weak self](data) in
            guard let `self` = self else {return}
            self.depositData = data
            if self.selectedIndex == .RECHARGE {
                self.endLoading()
                self.tableView.reloadData()
                if data.count == 0 {
                    self.tableView.showNoData(R.string.localizable.recode_nodata.key.localized(), icon: R.image.img_no_records.name)
                }
                else {
                    self.tableView.hiddenNoData()
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.withdrawIds.asObservable().skip(1).subscribe(onNext: { [weak self](data) in
            guard let `self` = self else { return }
            self.withdrawData = data
            if self.selectedIndex == .WITHDRAW {
                self.endLoading()
                self.tableView.reloadData()
                if data.count == 0 {
                    self.tableView.showNoData(R.string.localizable.recode_nodata.key.localized(), icon: R.image.img_no_records.name)
                }
                else {
                    self.tableView.hiddenNoData()
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension RechargeViewController {
    @objc func segmentTouch(_ data: [String: Any]) {
        guard let index = data["selectedIndex"] as? Int else {
            return
        }
        selectedIndex = index == 0 ? CellType.RECHARGE : CellType.WITHDRAW
        self.tableView?.reloadData()
    }
}
extension RechargeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == .WITHDRAW {
            if let data = self.withdrawData {
                return data.count
            }
            return 0
        }
        if let data = self.depositData {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: TradeCell.self), for: indexPath) as? TradeCell {
            if selectedIndex == .WITHDRAW {
                if let data = self.withdrawData {
                    cell.setup(data[indexPath.row])
                }
            } else {
                if let data = self.depositData {
                    cell.setup(data[indexPath.row])
                }
            }
            return cell
        }
        
        return TradeCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedIndex.rawValue {
        case 0:
            if let data = self.depositData {
                self.coordinator?.openWithDrawDetail(data[indexPath.row])
            }
        case 1:
            if let data = self.withdrawData {
                self.coordinator?.openRechargeDetail(data[indexPath.row])
            }
        default:
            break
        }
    }
}

extension RechargeViewController {
    @objc func rechargeHiddenAsset(_ data: [String: Any]) {
        guard let isEmpty = data["data"] as? Bool else {
            return
        }
        self.coordinator?.sortedEmptyAsset(isEmpty)
    }
    
    @objc func rechargeSortedName(_ data: [String: Any]) {
        guard let name = data["data"] as? String else { return }
        self.coordinator?.sortedNameAsset(name)
    }
}
