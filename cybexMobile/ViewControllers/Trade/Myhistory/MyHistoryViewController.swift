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

class MyHistoryViewController: BaseViewController {
    struct Define {
        static let sectionHeaderHeight: CGFloat = 44.0
    }

    var pair: Pair? {
        didSet {
            if let data = UserManager.shared.fillOrder.value {
                self.data = data
            }
        }
    }
    var data: [(FillOrder, String)]? {
        didSet {

        }
    }

    @IBOutlet weak var tableView: UITableView!

    var coordinator: (MyHistoryCoordinatorProtocol & MyHistoryStateManagerProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        self.localizedText = R.string.localizable.my_history_title.key.localizedContainer()
        let name = String.init(describing: MyHistoryCell.self)

        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
        if let data = self.data, data.count != 0 {
        } else {
            self.view.showNoData(R.string.localizable.myhistory_nodata.key.localized())
        }
    }

    override func configureObserveState() {
        UserManager.shared.fillOrder.asObservable()
            .skip(1)
            .throttle(10, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self](_) in
                guard let `self` = self else { return }

                if let data = UserManager.shared.fillOrder.value {
                    if data.count == 0 {
                        self.view.showNoData(R.string.localizable.myhistory_nodata.key.localized())
                    } else {
                        self.view.hiddenNoData()
                    }
                    self.data = data
                    if self.isVisible {
                        self.tableView.reloadData()
                    }
                }
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension MyHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = String.init(describing: MyHistoryCell.self)
        if let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as? MyHistoryCell {
            if let fillOrders = self.data {
                cell.setup(fillOrders[indexPath.row], indexPath: indexPath)
            }
            return cell
        }
        return MyHistoryCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: Define.sectionHeaderHeight))

        lockupAssetsSectionView.totalTitle.locali = R.string.localizable.order_history_first_title.key
        lockupAssetsSectionView.cybPriceTitle.locali = R.string.localizable.order_history_second_title.key
        return lockupAssetsSectionView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Define.sectionHeaderHeight
    }
}
