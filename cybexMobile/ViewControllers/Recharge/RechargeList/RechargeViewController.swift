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

    
    enum CELL_TYPE : Int{
        case RECHARGE
        case WITHDRAW
    }
    var selectedIndex : CELL_TYPE = .RECHARGE
    
    @IBOutlet weak var rechargeSegmentView: RechargeSegment!
    @IBOutlet weak var tableView: UITableView!
    var coordinator: (RechargeCoordinatorProtocol & RechargeStateManagerProtocol)?
    
    var depositData : [Trade]?
    var withdrawData : [Trade]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLoading()
        self.coordinator?.fetchDepositIdsInfo()
        self.coordinator?.fetchWithdrawIdsInfo()
        setupUI()
    }
    
    func setupUI(){
        self.localized_text = R.string.localizable.account_trade.key.localizedContainer()
        let cell = R.nib.tradeCell.name
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
        tableView.tableFooterView = UIView()
        rechargeSegmentView.segmentControl.selectedSegmentIndex = selectedIndex.rawValue
        configRightNavButton(R.image.ic_star_border_24_px())
    }
    
    override func rightAction(_ sender: UIButton) {
        self.coordinator?.openRecordList()
    }
    
    override func configureObserveState() {

        self.coordinator?.state.depositIds.asObservable().skip(1).subscribe(onNext: { [weak self](data) in
            guard let `self` = self else {return}
            self.depositData = self.filterData(data)
            if self.selectedIndex == .RECHARGE{
                self.endLoading()
                self.tableView.reloadData()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.coordinator?.state.withdrawIds.asObservable().skip(1).subscribe(onNext: { [weak self](data) in
            guard let `self` = self else { return }
            self.withdrawData = self.filterData(data)
            if self.selectedIndex == .WITHDRAW{
                self.endLoading()
                self.tableView.reloadData()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func filterData(_ trades:[Trade]) ->[Trade] {
        let data = trades.filter({return app_data.assetInfo[$0.id] != nil})
        var tradesInfo : [Trade] = []
        if var balances = UserManager.shared.balances.value{
            balances = balances.filter { (balance) -> Bool in
                return getRealAmount(balance.asset_type, amount: balance.balance).doubleValue != 0
            }
            for balance in balances{
                for trade in data{
                    if trade.id == balance.asset_type {
                        tradesInfo.append(trade)
                    }
                }
            }
            let filterData = data.filter { (trade) -> Bool in
                for tradeInfo in tradesInfo{
                    if tradeInfo.id == trade.id {
                        return false
                    }
                }
                return true
            }
            return tradesInfo + filterData
        }
        return data
    }
}

extension RechargeViewController {
    @objc func segmentTouch(_ data:[String:Any]){
        selectedIndex = (data["selectedIndex"] as! Int) == 0 ? CELL_TYPE.RECHARGE : CELL_TYPE.WITHDRAW
        self.tableView!.reloadData()
    }
}
extension RechargeViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == .WITHDRAW{
            if let data = self.withdrawData{
                return data.count
            }
            return 0
        }
        if let data = self.depositData{
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing:TradeCell.self), for: indexPath) as! TradeCell
        if selectedIndex == .WITHDRAW {
            if let data = self.withdrawData{
                cell.setup(data[indexPath.row])
            }
        }else{
            if let data = self.depositData{
                cell.setup(data[indexPath.row])
            }
        }
        return cell
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
