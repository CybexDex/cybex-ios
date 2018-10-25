//
//  LockupAssetsViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import TinyConstraints

import SwiftyJSON

class LockupAssetsViewController: BaseViewController {

    struct define {
        static let sectionHeaderHeight: CGFloat = 44.0
    }

    @IBOutlet weak var tableView: UITableView!
    var coordinator: (LockupAssetsCoordinatorProtocol & LockupAssetsStateManagerProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.startLoading()
        self.coordinator?.fetchLockupAssetsData([UserManager.shared.keys!.active_key!.address, UserManager.shared.keys!.active_key!.compressed, UserManager.shared.keys!.active_key!.uncompressed, UserManager.shared.keys!.owner_key!.address, UserManager.shared.keys!.owner_key!.compressed, UserManager.shared.keys!.owner_key!.uncompressed, UserManager.shared.keys!.memo_key!.address, UserManager.shared.keys!.memo_key!.compressed, UserManager.shared.keys!.memo_key!.uncompressed])
    }

    func setupUI() {
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.localized_text = R.string.localizable.lockupAssetsTitle.key.localizedContainer()
        let cell = String.init(describing: LockupAssetsCell.self)
        tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
    }

    override func configureObserveState() {
        self.coordinator?.state.property.data.asObservable().skip(1).subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else {return}
            self.endLoading()
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

// MARK: UITableViewDataSource

extension LockupAssetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = coordinator!.state.property.data.value
        return data.datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: LockupAssetsCell.self), for: indexPath) as! LockupAssetsCell
        let data = coordinator!.state.property.data.value

        cell.setup(data.datas[indexPath.row], indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: define.sectionHeaderHeight))

        return lockupAssetsSectionView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return define.sectionHeaderHeight
    }

}
