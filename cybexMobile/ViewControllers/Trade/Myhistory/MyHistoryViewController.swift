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
import SwiftyJSON

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
            })
        }
    }

    func fetchData(_ page: Int, callback: ((Bool) -> Void)?) {
        if case let .fillOrder(pair: pair) = type {
            let oid: String? = self.page == 0 ? nil : self.data.last?.oid
            if let pair = pair {
                self.coordinator?.fetchMyOrderHistory(pair, lessThanOrderId: oid, callback: callback)
            }
            else {
                self.coordinator?.fetchAllMyOrderHistory(oid, callback: callback)
            }
        }
        else if case let .groupFillOrder(pair: pair) = type, let uid = UserManager.shared.getCachedAccount()?.id {
            if pair == nil { // 个人页面
                let fin: [Pair] = MarketConfiguration.shared.marketPairs.value

                AccountHistoryService.request(target: AccountHistoryAPI.getFillByPairs(userId: uid, page: page, filterInPairs: fin, filterOutPairs: []), success: { (json) in
                    self.endLoading()
                    self.handlerDataFetched(json, callback: callback)
                }, error: { (error) in
                    self.endAllLoading(self.tableView)
                }) { (error) in
                    self.endAllLoading(self.tableView)
                }
            } else {
                AccountHistoryService.request(target: AccountHistoryAPI.getFillByPairs(userId: uid, page: page, filterInPairs: [pair!], filterOutPairs: []), success: { (json) in
                    self.endLoading()
                    self.handlerDataFetched(json, callback: callback)

                }, error: { (error) in
                    self.endAllLoading(self.tableView)
                }) { (error) in
                    self.endAllLoading(self.tableView)
                }
            }
        }
        else {
            self.endLoading()

            if self.data.count == 0 {
                self.view.showNoData(R.string.localizable.myhistory_nodata.key.localized(), icon: R.image.img_no_records.name)
                return
            }
            else {
                self.view.hiddenNoData()
            }
        }
    }

    func handlerDataFetched(_ json: JSON, callback: ((Bool) -> Void)?) {
        guard let ops = json.arrayValue.first?.arrayValue else {
            callback?(true)
            return
        }

        let times = ops.map({ $0["timestamp"].stringValue })

        if let model = [FillOrder].deserialize(from: ops.compactMap { $0["op"][1].dictionaryObject }) as? [FillOrder] {
            var vmData: [MyHistoryCellView.ViewModel] = []
            for (i, v) in model.enumerated() {
                vmData.append(MyHistoryCellView.ViewModel.makeViewModelFrom(data: v, orginTime: times[i]))
            }

            if self.page == 0 {
                if vmData.count < 20 {
                    self.tableView.es.noticeNoMoreData()
                }
                else {
                    self.tableView.es.resetNoMoreData()
                }
                self.data = vmData
            }
            else {
                self.data.append(contentsOf: vmData)
            }

            if self.data.count == 0 {
                self.view.showNoData(R.string.localizable.myhistory_nodata.key.localized(), icon: R.image.img_no_records.name)
                return
            }
            else {
                self.view.hiddenNoData()
            }

            self.tableView.reloadData()
            callback?(vmData.count != 20)
            self.stopInfiniteScrolling(self.tableView, haveNoMore: (vmData.count != 20))
        }
    }

    override func configureObserveState() {
        self.coordinator?.state.fillOrders.asObservable().skip(1).subscribe(onNext: {[weak self] (data) in
            guard let self = self else { return }
            self.endLoading()

            guard data.count != 0 else {
                if self.data.count == 0 {
                    self.view.showNoData(R.string.localizable.closedorder_nodata.key.localized(), icon: R.image.img_no_records.name)
                    return
                }
                else {
                    self.view.hiddenNoData()
                }

                return
            }
            self.view.hiddenNoData()

            let newData = data.map({ MyHistoryCellView.ViewModel.makeViewModelFrom(data: $0) })

            if self.page == 0 {
                if newData.count < 20 {
                    self.tableView.es.noticeNoMoreData()
                }
                else {
                    self.tableView.es.resetNoMoreData()
                }
                self.data = newData
            }
            else {
                self.data.append(contentsOf: newData)
            }

            self.tableView.reloadData()
            self.stopInfiniteScrolling(self.tableView, haveNoMore: (data.count != 20))

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
            return cell
        }
        return MyHistoryCell()
    }
}
