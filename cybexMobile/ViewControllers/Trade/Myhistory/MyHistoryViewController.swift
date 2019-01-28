//
//  MyHistoryViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import XLPagerTabStrip
import SwiftTheme

class MyHistoryViewController: BaseViewController, IndicatorInfoProvider {

    @IBOutlet weak var leftHint: UILabel!
    @IBOutlet weak var middleHint: UILabel!
    @IBOutlet weak var rightHint: UILabel!

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        switch type {
        case .fillOrder(pair: _):
            return IndicatorInfo(title: R.string.localizable.orders_my_filled_order.key.localized())
        case .groupFillOrder(pair: _):
            return IndicatorInfo(title: R.string.localizable.orders_my_trade_history.key.localized())

        }
    }

    enum PageType {
        case fillOrder(pair: Pair?)
        case groupFillOrder(pair: Pair?)
    }

    var type: PageType = .fillOrder(pair: nil)

    var data: [MyHistoryCellView.ViewModel] = []

    var page: Int = 0

    @IBOutlet weak var tableView: UITableView!

    var coordinator: (MyHistoryCoordinatorProtocol & MyHistoryStateManagerProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        
        self.coordinator?.connect()
        self.startLoading()
        fetchData(0, callback: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]
    }

    func setupUI() {
        self.localizedText = R.string.localizable.my_history_title.key.localizedContainer()

        leftHint.locali = R.string.localizable.orders_title_market.key

        if case .fillOrder = type {
            middleHint.locali = R.string.localizable.orders_my_filled_order_title_mid.key
            rightHint.locali = R.string.localizable.orders_my_filled_order_title_trail.key
        }
        else {
            middleHint.locali = R.string.localizable.orders_my_trade_history_title_mid.key
            rightHint.locali = R.string.localizable.orders_my_trade_history_title_trail.key
        }

        let name = String.init(describing: MyHistoryCell.self)

        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }

    func setupTableView() {
        self.addPullToRefresh(self.tableView) {[weak self] (completion) in
            guard let self = self else { return }

            self.page = 0
            self.fetchData(self.page, callback: { (noMoreData) in
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
            self.fetchData(self.page, callback: { (noMoreData) in
                completion?(noMoreData)
            })
        }
    }

    func fetchData(_ page: Int, callback: ((Bool) -> Void)?) {
        if case let .fillOrder(pair: pair) = type {
            if let pair = pair {
                self.coordinator?.fetchMyOrderHistory(pair, page: page, callback: callback)
            }
            else {
                self.coordinator?.fetchAllMyOrderHistory(page, callback: callback)
            }
        }
        else if case let .groupFillOrder(pair: pair) = type, let uid = UserManager.shared.account.value?.id {
            AccountHistoryService.request(target: .getMyGroupFillOrder(userId: uid, pair: pair, page: page), success: { (json) in
                self.endLoading()

                let times = json.arrayValue.map({ $0["timestamp"].stringValue })

                if let model = [FillOrder].deserialize(from: json.arrayValue.compactMap { $0["op"][1].dictionaryObject }) as? [FillOrder] {
                    var vmData: [MyHistoryCellView.ViewModel] = []
                    for (i, v) in model.enumerated() {
                        vmData.append(MyHistoryCellView.ViewModel.makeViewModelFrom(data: v, orginTime: times[i]))
                    }

                    if self.page == 0 {
                        self.data = vmData
                    }
                    else {
                        self.data.append(contentsOf: vmData)
                    }

                    callback?(vmData.count != 20)
                    self.tableView.reloadData()
                }

            }, error: { (error) in
                self.endLoading()
            }) { (error) in
                self.endLoading()
            }
        }
    }

    override func configureObserveState() {
        self.coordinator?.state.fillOrders.asObservable().subscribe(onNext: {[weak self] (data) in
            guard let self = self else { return }
            self.endLoading()

            let newData = data.map({ MyHistoryCellView.ViewModel.makeViewModelFrom(data: $0) })

            if self.page == 0 {
                self.data = newData
            }
            else {
                self.data.append(contentsOf: newData)
            }
            self.tableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension MyHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = String.init(describing: MyHistoryCell.self)
        if let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as? MyHistoryCell {
            let model = self.data[indexPath.row]

            cell.setup(model, indexPath: indexPath)

            let canceledSelectedColor: UIColor = ThemeManager.currentThemeIndex == 0 ? .darkFour : .steel20
            cell.contentView.backgroundColor = model.isCanceled ? canceledSelectedColor : .clear
            
            return cell
        }
        return MyHistoryCell()
    }
}
